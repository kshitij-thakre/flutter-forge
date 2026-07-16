import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:args/args.dart';
import 'github_bootstrap_impl/models.dart';
import 'github_bootstrap_impl/yaml_parser.dart';
import 'github_bootstrap_impl/logger.dart';
import 'github_bootstrap_impl/retry_handler.dart';
import 'github_bootstrap_impl/github_api_client.dart';
import 'github_bootstrap_impl/validation_service.dart';
import 'github_bootstrap_impl/bootstrap_service.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('config', abbr: 'c', defaultsTo: 'roadmaps/v3.yaml', help: 'Path to the roadmap YAML configuration file.')
    ..addOption('owner', abbr: 'o', defaultsTo: 'kshitij-thakre', help: 'GitHub repository owner.')
    ..addOption('repo', abbr: 'r', defaultsTo: 'flutter-forge', help: 'GitHub repository name.')
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Print CLI usage directions.');

  ArgResults argResults;
  try {
    argResults = parser.parse(arguments);
  } catch (e) {
    print('Failed to parse CLI options: $e\n');
    _printUsage(parser);
    exit(1);
  }

  if (argResults['help'] as bool) {
    _printUsage(parser);
    exit(0);
  }

  final command = argResults.rest.isNotEmpty ? argResults.rest.first : '';
  if (command.isEmpty) {
    print('No execution command specified.\n');
    _printUsage(parser);
    exit(1);
  }

  final configPath = argResults['config'] as String;
  final owner = argResults['owner'] as String;
  final repo = argResults['repo'] as String;
  final token = Platform.environment['GITHUB_TOKEN'] ?? '';

  final logger = Logger();
  final yamlParser = YamlParser();
  final retryHandler = RetryHandler(logger);
  final httpClient = http.Client();
  final apiClient = GitHubApiClient(
    client: httpClient,
    token: token,
    retryHandler: retryHandler,
  );
  final validationService = ValidationService(apiClient: apiClient);
  final bootstrapService = BootstrapService(
    apiClient: apiClient,
    logger: logger,
    yamlParser: yamlParser,
    validationService: validationService,
  );

  RoadmapConfig roadmapConfig;
  try {
    roadmapConfig = yamlParser.parse(configPath);
  } catch (e) {
    logger.error('Failed to load or parse roadmap configuration file: $e');
    httpClient.close();
    exit(1);
  }

  try {
    switch (command) {
      case 'validate':
        logger.bold('Running offline and online validation diagnostics...');
        final result = await validationService.validate(
          roadmapConfig,
          owner: owner,
          repo: repo,
          token: token,
        );
        for (final warn in result.warnings) {
          logger.warning(warn);
        }
        if (result.isValid) {
          logger.success('Validation completed successfully. Ready for bootstrap.');
          httpClient.close();
          exit(0);
        } else {
          for (final err in result.errors) {
            logger.error(err);
          }
          logger.error('Validation failed with errors.');
          httpClient.close();
          exit(1);
        }

      case 'verify':
        logger.bold('Executing alignment validation report...');
        final matches = await bootstrapService.runVerify(
          config: roadmapConfig,
          owner: owner,
          repo: repo,
          token: token,
        );
        if (matches) {
          logger.success('Repository is 100% aligned with the roadmap configuration.');
          httpClient.close();
          exit(0);
        } else {
          logger.error('Repository state is not aligned with the roadmap configuration.');
          httpClient.close();
          exit(1);
        }

      case 'dry-run':
        logger.bold('Executing dry-run project simulation...');
        await bootstrapService.runBootstrap(
          config: roadmapConfig,
          owner: owner,
          repo: repo,
          token: token,
          isDryRun: true,
        );
        httpClient.close();
        exit(0);

      case 'bootstrap':
        logger.bold('Starting active GitHub roadmap bootstrap execution...');
        await bootstrapService.runBootstrap(
          config: roadmapConfig,
          owner: owner,
          repo: repo,
          token: token,
          isDryRun: false,
        );
        httpClient.close();
        exit(0);

      case 'delete-release':
        if (argResults.rest.length < 2) {
          logger.error('Missing target release version tag (e.g. 3.0).');
          logger.info('Usage: dart run tool/github_bootstrap delete-release <version>');
          httpClient.close();
          exit(1);
        }
        final versionTag = argResults.rest[1];
        logger.bold('Syncing delete release targets for version tag $versionTag...');
        await bootstrapService.deleteRelease(
          config: roadmapConfig,
          owner: owner,
          repo: repo,
          token: token,
          versionTag: versionTag,
        );
        httpClient.close();
        exit(0);

      default:
        logger.error('Unknown execution command: $command\n');
        _printUsage(parser);
        httpClient.close();
        exit(1);
    }
  } catch (e) {
    logger.error('Fatal CLI execution error: $e');
    httpClient.close();
    exit(1);
  }
}

void _printUsage(ArgParser parser) {
  print('GitHub Roadmap Bootstrap Tool\n');
  print('Usage: dart run tool/github_bootstrap <command> [options]\n');
  print('Commands:');
  print('  validate          Validate token presence, API connection, and configuration checks.');
  print('  verify            Compare current repository state with config and report alignment.');
  print('  dry-run           Simulate syncing milestones, labels, and issue creation.');
  print('  bootstrap         Sync milestones, labels, and populate issues directly on GitHub.');
  print('  delete-release    Delete milestones and close issues associated with a release version.\n');
  print('Options:');
  print(parser.usage);
}

import 'dart:io';
import 'package:ironship/services/flutter_service.dart';
import 'package:ironship/generators/project_generator.dart';
import 'package:ironship/services/discovery_pipeline_service.dart';
import 'package:ironship/services/architecture_recommendation_service.dart';
import 'package:ironship/services/project_blueprint_service.dart';
import 'package:ironship/services/configuration_service.dart';
import 'package:ironship/services/package_installer_service.dart';
import 'package:ironship/generators/state_management_generator.dart';
import 'package:ironship/generators/router_generator.dart';
import 'package:ironship/generators/session_generator.dart';
import 'package:ironship/generators/environment_generator.dart';
import 'package:ironship/models/final_project_blueprint.dart';

class InitCommand {
  final String name = 'init';
  final String description = 'Initialize a new Flutter project pre-configured with the Forge architecture.';

  static Future<void> execute(String projectName) async {
    final nameRegex = RegExp(r'^[a-z][a-z0-9_]*$');
    if (!nameRegex.hasMatch(projectName)) {
      print('Invalid project name.');
      print('Project names must contain lowercase letters, numbers and underscores only.');
      return;
    }

    final directory = Directory(projectName);
    if (await directory.exists()) {
      print('Project already exists.');
      print('Choose another name or delete the existing directory.');
      return;
    }

    final flutterService = FlutterService();
    final isInstalled = await flutterService.isFlutterInstalled();
    if (!isInstalled) {
      print('Flutter SDK not found. Please install Flutter and add it to PATH.');
      return;
    }

    try {
      final version = await flutterService.getFlutterVersion();
      print('Flutter detected: $version');
    } catch (e) {
      print('Flutter SDK not found. Please install Flutter and add it to PATH.');
      return;
    }

    // 1. Questionnaire & Discovery
    final discoveryPipeline = DiscoveryPipelineService();
    final projectConfig = await discoveryPipeline.execute(projectName);

    // 2. Recommendation
    final recommendationService = ArchitectureRecommendationService();
    final recommendation = recommendationService.recommend(projectConfig);

    // 3. Developer Overrides (Questionnaire defaults)
    String? overrideStateManagement;
    if (projectConfig.requirements.stateManagement != 'Recommend for me') {
      overrideStateManagement = projectConfig.requirements.stateManagement;
    }
    String? overrideRouting;
    if (projectConfig.requirements.routing != 'Recommend for me') {
      overrideRouting = projectConfig.requirements.routing;
    }

    String? overrideSessionStrategy;
    String? overrideEnvironmentStrategy;

    print('\n==================================================');
    print('          Recommended Architecture Configuration');
    print('==================================================');
    print('State Management:     ${overrideStateManagement ?? recommendation.recommendedStateManagement}');
    print('Routing Solution:     ${overrideRouting ?? recommendation.recommendedRouting}');
    print('Session Strategy:     ${recommendation.sessionStrategy}');
    print('Environment Strategy: ${recommendation.environmentStrategy}');
    print('==================================================\n');

    // 4. Developer Override Prompt
    stdout.write('Do you want to override these selections? (y/N): ');
    final overrideChoice = stdin.readLineSync()?.trim().toLowerCase();
    if (overrideChoice == 'y' || overrideChoice == 'yes') {
      print('\nEnter override options (leave blank to accept recommendation/current choice):');
      
      stdout.write('State Management (Riverpod, Bloc, Provider, GetX): ');
      final stateInput = stdin.readLineSync()?.trim();
      if (stateInput != null && stateInput.isNotEmpty) {
        overrideStateManagement = stateInput;
      }

      stdout.write('Routing Solution (Go Router, Navigation 2.0, Auto Route, Beamer): ');
      final routingInput = stdin.readLineSync()?.trim();
      if (routingInput != null && routingInput.isNotEmpty) {
        overrideRouting = routingInput;
      }

      stdout.write('Session Strategy (Persistent Session, Secure Storage, Shared Preferences, Memory Session): ');
      final sessionInput = stdin.readLineSync()?.trim();
      if (sessionInput != null && sessionInput.isNotEmpty) {
        overrideSessionStrategy = sessionInput;
      }

      stdout.write('Environment Strategy (Development only, Single environment setup, Dev + Production, Dev + Stage + Production, Environment Configuration Setup, Environment Configuration Strategy, Custom environment): ');
      final envInput = stdin.readLineSync()?.trim();
      if (envInput != null && envInput.isNotEmpty) {
        overrideEnvironmentStrategy = envInput;
      }
    }

    // 5. Compatibility Validation
    FinalProjectBlueprint blueprint;
    try {
      final blueprintService = ProjectBlueprintService();
      blueprint = await blueprintService.buildBlueprint(
        projectConfig,
        overrideStateManagement: overrideStateManagement,
        overrideRouting: overrideRouting,
        overrideSessionStrategy: overrideSessionStrategy,
        overrideEnvironmentStrategy: overrideEnvironmentStrategy,
      );
    } catch (e) {
      print('\n[ERROR] Compatibility validation failed:');
      print(e);
      return;
    }

    print('\nFinalizing Project Blueprint...');
    print(blueprint);

    // 6. Flutter Project Creation
    print('\nCreating Flutter project structure...');
    await flutterService.createFlutterProject(projectName);
    print('Project created successfully.');

    // 7. Persistence
    print('Saving configuration file...');
    final configService = ConfigurationService();
    await configService.save('$projectName/forge_config.json', projectConfig);
    print('Configuration saved to $projectName/forge_config.json.');

    // 8. Inject Base Architecture folders
    print('Injecting architecture layers...');
    final projectGenerator = ProjectGenerator();
    await projectGenerator.injectArchitectureFolders(projectName);
    await projectGenerator.scaffoldAppException(projectName);
    await projectGenerator.scaffoldApiResult(projectName);
    await projectGenerator.scaffoldExceptionMapper(projectName);
    await projectGenerator.scaffoldDioClient(projectName);
    print('Architecture layers injected.');

    // 9. Specific Generators execution
    print('Generating architecture modules...');
    final stateMeta = await StateManagementGenerator().generate(projectName, blueprint);
    final routerMeta = await RouterGenerator().generate(projectName, blueprint);

    Map<String, dynamic>? sessionMeta;
    if (SessionGenerator().supports(blueprint.sessionStrategy)) {
      sessionMeta = await SessionGenerator().generate(projectName, blueprint);
    }

    Map<String, dynamic>? envMeta;
    if (EnvironmentGenerator().supports(blueprint.environmentStrategy)) {
      envMeta = await EnvironmentGenerator().generate(projectName, blueprint);
    }

    // 10. Package Aggregation
    print('Aggregating dependencies...');
    final packages = <String>{'dio'};
    if (stateMeta['packagesToAdd'] != null) {
      packages.addAll(List<String>.from(stateMeta['packagesToAdd']));
    }
    if (routerMeta['packagesToAdd'] != null) {
      packages.addAll(List<String>.from(routerMeta['packagesToAdd']));
    }
    if (sessionMeta != null && sessionMeta['packagesToAdd'] != null) {
      packages.addAll(List<String>.from(sessionMeta['packagesToAdd']));
    }
    if (envMeta != null && envMeta['packagesToAdd'] != null) {
      packages.addAll(List<String>.from(envMeta['packagesToAdd']));
    }

    print('Installing aggregated dependencies: ${packages.join(", ")}...');
    final installer = PackageInstallerService();
    await installer.install(projectName, packages.toList());
    print('Dependencies installed successfully.');
    print('\nIronship Project Initialization complete!');
  }

  Future<void> run(List<String> arguments) async {
    // TODO: Parse options like project name, custom state management or routing package.
  }
}

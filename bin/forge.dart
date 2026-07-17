import 'dart:io';
import 'package:args/args.dart';
import 'package:ironship/commands/command_registry.dart';
import 'package:ironship/commands/init_command.dart';
import 'package:ironship/commands/help_command.dart';
import 'package:ironship/commands/version_command.dart';
import 'package:ironship/commands/doctor_command.dart';
import 'package:ironship/commands/feature_command.dart';
import 'package:ironship/commands/module_command.dart';
import 'package:ironship/commands/blueprint_command.dart';
import 'package:ironship/commands/docs_command.dart';
import 'package:ironship/commands/score_command.dart';

void main(List<String> arguments) async {
  final registry = CommandRegistry();

  registry.register(InitCommand());
  registry.register(HelpCommand(registry));
  registry.register(VersionCommand());
  registry.register(DoctorCommand());
  registry.register(FeatureCommand());
  registry.register(ModuleCommand());
  registry.register(BlueprintCommand());
  registry.register(DocsCommand());
  registry.register(ScoreCommand());

  final parser = ArgParser()
    ..addFlag('help',
        abbr: 'h', negatable: false, help: 'Show help information.')
    ..addFlag('version', negatable: false, help: 'Show version information.');

  ArgResults results;
  try {
    results = parser.parse(arguments);
  } catch (e) {
    print('Error: $e');
    registry.printHelp();
    exit(1);
  }

  if (results['help'] as bool) {
    registry.printHelp();
    exit(0);
  }

  if (results['version'] as bool) {
    final version = await VersionCommand.getVersion();
    print('Forge version: $version');
    exit(0);
  }

  if (results.rest.isEmpty) {
    registry.printHelp();
    exit(0);
  }

  final cmdName = results.rest.first;
  final cmdArgs = results.rest.sublist(1);

  if (!registry.hasCommand(cmdName)) {
    print('Error: Unknown command: $cmdName');
    registry.printHelp();
    exit(1);
  }

  final command = registry.getCommand(cmdName)!;
  final exitCode = await command.execute(cmdArgs);
  exit(exitCode);
}

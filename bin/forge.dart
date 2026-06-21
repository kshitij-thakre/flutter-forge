/// Responsibility:
/// Entry point for the Flutter Forge CLI tool.
/// Parses command line arguments and dispatches commands.

import 'dart:io';
import 'package:flutter_forge_cli/commands/init_command.dart';
import 'package:flutter_forge_cli/commands/add_feature_command.dart';

void main(List<String> arguments) async {
  if (arguments.isEmpty) {
    print('Usage: forge init <project_name>');
    exit(0);
  }

  final command = arguments.first;
  if (command == 'init') {
    if (arguments.length < 2) {
      print('Usage: forge init <project_name>');
      exit(1);
    }
    final projectName = arguments[1];
    await InitCommand.execute(projectName);
  } else if (command == 'add') {
    if (arguments.length < 3 || arguments[1] != 'feature') {
      print('Usage: forge add feature <feature_name>');
      exit(1);
    }
    final featureName = arguments[2];
    await AddFeatureCommand.execute('.', featureName);
  } else {
    print('Unknown command: $command');
    exit(1);
  }
}

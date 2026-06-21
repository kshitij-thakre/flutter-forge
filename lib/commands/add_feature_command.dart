import 'dart:io';
import 'package:flutter_forge_cli/generators/feature_generator.dart';

class AddFeatureCommand {
  final String name = 'add';
  final String description = 'Scaffold a new Clean Architecture feature module.';

  static Future<void> execute(String projectPath, String featureName) async {
    final baseDir = projectPath.endsWith('/')
        ? projectPath.substring(0, projectPath.length - 1)
        : projectPath;

    final featureDir = Directory('$baseDir/lib/features/$featureName');
    if (await featureDir.exists()) {
      print('Feature already exists.');
      print('Choose another name.');
      return;
    }

    print('Generating feature...');
    final generator = FeatureGenerator();
    await generator.generateFeature(projectPath, featureName);
    print('Feature created successfully.');
  }

  Future<void> run(List<String> arguments) async {
    // TODO: Parse options like feature name.
  }
}

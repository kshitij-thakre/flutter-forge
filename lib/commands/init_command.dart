import 'dart:io';
import 'package:flutter_forge_cli/services/flutter_service.dart';
import 'package:flutter_forge_cli/generators/project_generator.dart';

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

    try {
      await flutterService.createFlutterProject(projectName);
      print('Project created successfully.');
      
      print('Injecting architecture...');
      final generator = ProjectGenerator();
      await generator.injectArchitectureFolders(projectName);
      print('Architecture injected successfully.');

      print('Installing dependencies...');
      await generator.installDependencies(projectName);
      print('Dependencies installed successfully.');

      print('Scaffolding foundation templates...');
      await generator.scaffoldAppException(projectName);
      await generator.scaffoldApiResult(projectName);
      await generator.scaffoldExceptionMapper(projectName);
      await generator.scaffoldDioClient(projectName);
      print('Foundation templates created.');
    } catch (e) {
      print('Failed to create Flutter project: $e');
    }
  }

  Future<void> run(List<String> arguments) async {
    // TODO: Parse options like project name, custom state management or routing package.
  }
}

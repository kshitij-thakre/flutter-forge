import 'package:flutter_forge/services/flutter_service.dart';

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
    } catch (e) {
      print('Failed to create Flutter project: $e');
    }
  }

  Future<void> run(List<String> arguments) async {
    // TODO: Parse options like project name, custom state management or routing package.
  }
}

/// Responsibility:
/// Runs flutter create and validates Flutter installation.
/// Interacts with local system shell to run flutter sdk actions (e.g. pub get).

import 'dart:io';

class FlutterService {
  // TODO: Check if flutter command exists on PATH.
  // TODO: Implement wrapper to execute standard Process.run('flutter', ['create', ...]).
  // TODO: Implement wrapper to execute Process.run('flutter', ['pub', 'get', ...]).

  Future<bool> isFlutterInstalled() async {
    try {
      final result = await Process.run('flutter', ['--version']);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  Future<String> getFlutterVersion() async {
    try {
      final result = await Process.run('flutter', ['--version']);
      if (result.exitCode != 0) {
        throw ProcessException(
            'flutter',
            ['--version'],
            'Flutter command returned exit code ${result.exitCode}',
            result.exitCode);
      }
      final stdout = result.stdout as String;
      final firstLine = stdout
          .split('\n')
          .firstWhere((line) => line.trim().isNotEmpty, orElse: () => '');
      if (firstLine.isEmpty) {
        throw const FormatException('Flutter version output was empty.');
      }
      final parts = firstLine.split('•');
      return parts.first.trim();
    } catch (e) {
      throw Exception('Flutter SDK is not available or returned an error: $e');
    }
  }

  Future<void> createFlutterProject(String projectName) async {
    try {
      final result = await Process.run('flutter', ['create', projectName]);
      if (result.exitCode != 0) {
        final stderrOutput = result.stderr as String;
        throw ProcessException(
          'flutter',
          ['create', projectName],
          stderrOutput,
          result.exitCode,
        );
      }
    } catch (e) {
      if (e is ProcessException) rethrow;
      throw Exception('Failed to execute flutter create: $e');
    }
  }

  Future<void> createProject({
    required String projectName,
    required String path,
  }) async {
    await createFlutterProject(projectName);
  }

  Future<void> runPubGet({required String path}) async {
    // TODO: Execute flutter pub get inside the path.
  }
}

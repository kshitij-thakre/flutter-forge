import 'dart:io';

class PackageInstallerService {
  Future<void> install(String projectPath, List<String> packages) async {
    if (packages.isEmpty) return;

    final baseDir = projectPath.endsWith('/')
        ? projectPath.substring(0, projectPath.length - 1)
        : projectPath;

    final result = await Process.run(
      'flutter',
      ['pub', 'add', ...packages],
      workingDirectory: baseDir,
    );

    if (result.exitCode != 0) {
      throw ProcessException(
        'flutter',
        ['pub', 'add', ...packages],
        result.stderr as String,
        result.exitCode,
      );
    }
  }
}

import 'dart:io';
import 'package:yaml/yaml.dart';
import 'command.dart';

class VersionCommand implements Command {
  @override
  String get name => 'version';

  @override
  String get description => 'Show version information.';

  @override
  Future<int> execute(List<String> args) async {
    final version = await getVersion();
    print('Forge version: $version');
    return 0;
  }

  static Future<String> getVersion() async {
    // 1. Check Platform.script
    try {
      final scriptUri = Platform.script;
      if (scriptUri.scheme == 'file') {
        final scriptFile = File(scriptUri.toFilePath());
        Directory dir = scriptFile.parent;
        while (dir.path != dir.parent.path) {
          final pubspec = File('${dir.path}/pubspec.yaml');
          if (await pubspec.exists()) {
            final content = await pubspec.readAsString();
            final doc = loadYaml(content) as YamlMap;
            final version = doc['version'] as String?;
            if (version != null) return version;
          }
          dir = dir.parent;
        }
      }
    } catch (_) {}

    // 2. Fallback to current working directory
    try {
      final pubspec = File('pubspec.yaml');
      if (await pubspec.exists()) {
        final content = await pubspec.readAsString();
        final doc = loadYaml(content) as YamlMap;
        final version = doc['version'] as String?;
        if (version != null) return version;
      }
    } catch (_) {}

    return 'unknown';
  }
}

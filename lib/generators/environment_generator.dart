import 'dart:io';
import '../models/final_project_blueprint.dart';

class EnvironmentGenerator {
  bool supports(String environmentStrategy) {
    final normalized = environmentStrategy.trim().toLowerCase();
    return normalized == 'development only' ||
        normalized == 'single environment setup' ||
        normalized == 'dev + production' ||
        normalized == 'dev + stage + production' ||
        normalized == 'environment configuration setup' ||
        normalized == 'environment configuration strategy' ||
        normalized == 'custom environment';
  }

  Future<Map<String, dynamic>> generate(
    String projectPath,
    FinalProjectBlueprint blueprint,
  ) async {
    final environmentStrategy = blueprint.environmentStrategy;
    if (!supports(environmentStrategy)) {
      throw ArgumentError(
          'Unsupported environment strategy: $environmentStrategy');
    }

    final normalized = environmentStrategy.trim().toLowerCase();
    final metadata = <String, dynamic>{
      'environmentStrategy': environmentStrategy,
      'generatedDirectories': <String>[],
      'generatedFiles': <String>[],
      'packagesToAdd': <String>[],
    };

    final configDir = Directory('$projectPath/lib/core/config');

    if (normalized == 'development only' ||
        normalized == 'single environment setup') {
      if (!await configDir.exists()) {
        await configDir.create(recursive: true);
      }
      final file = File('${configDir.path}/env.dart');
      await file.writeAsString('''
// Environment: Development Only Setup
class Env {
  static const String environment = 'development';
  static const String apiBaseUrl = 'https://dev.api.example.com';
}
''');
      metadata['generatedDirectories'].add('lib/core/config');
      metadata['generatedFiles'].add('lib/core/config/env.dart');
    } else if (normalized == 'dev + production') {
      if (!await configDir.exists()) {
        await configDir.create(recursive: true);
      }
      final fileEnv = File('${configDir.path}/env.dart');
      await fileEnv.writeAsString('''
// Environment: Base Config
abstract class Env {
  String get apiBaseUrl;
  String get environment;
}
''');
      final fileDev = File('${configDir.path}/env_dev.dart');
      await fileDev.writeAsString('''
// Environment: Development Config
import 'env.dart';

class DevEnv implements Env {
  @override
  final String environment = 'development';
  @override
  final String apiBaseUrl = 'https://dev.api.example.com';
}
''');
      final fileProd = File('${configDir.path}/env_prod.dart');
      await fileProd.writeAsString('''
// Environment: Production Config
import 'env.dart';

class ProdEnv implements Env {
  @override
  final String environment = 'production';
  @override
  final String apiBaseUrl = 'https://api.example.com';
}
''');
      metadata['generatedDirectories'].add('lib/core/config');
      metadata['generatedFiles'].add('lib/core/config/env.dart');
      metadata['generatedFiles'].add('lib/core/config/env_dev.dart');
      metadata['generatedFiles'].add('lib/core/config/env_prod.dart');
    } else if (normalized == 'dev + stage + production' ||
        normalized == 'environment configuration setup' ||
        normalized == 'environment configuration strategy') {
      if (!await configDir.exists()) {
        await configDir.create(recursive: true);
      }
      final fileEnv = File('${configDir.path}/env.dart');
      await fileEnv.writeAsString('''
// Environment: Base Config
abstract class Env {
  String get apiBaseUrl;
  String get environment;
}
''');
      final fileDev = File('${configDir.path}/env_dev.dart');
      await fileDev.writeAsString('''
// Environment: Development Config
import 'env.dart';

class DevEnv implements Env {
  @override
  final String environment = 'development';
  @override
  final String apiBaseUrl = 'https://dev.api.example.com';
}
''');
      final fileStage = File('${configDir.path}/env_stage.dart');
      await fileStage.writeAsString('''
// Environment: Staging Config
import 'env.dart';

class StageEnv implements Env {
  @override
  final String environment = 'staging';
  @override
  final String apiBaseUrl = 'https://staging.api.example.com';
}
''');
      final fileProd = File('${configDir.path}/env_prod.dart');
      await fileProd.writeAsString('''
// Environment: Production Config
import 'env.dart';

class ProdEnv implements Env {
  @override
  final String environment = 'production';
  @override
  final String apiBaseUrl = 'https://api.example.com';
}
''');
      metadata['generatedDirectories'].add('lib/core/config');
      metadata['generatedFiles'].add('lib/core/config/env.dart');
      metadata['generatedFiles'].add('lib/core/config/env_dev.dart');
      metadata['generatedFiles'].add('lib/core/config/env_stage.dart');
      metadata['generatedFiles'].add('lib/core/config/env_prod.dart');
    } else if (normalized == 'custom environment') {
      if (!await configDir.exists()) {
        await configDir.create(recursive: true);
      }
      final file = File('${configDir.path}/custom_env.dart');
      await file.writeAsString('''
// Environment: Custom Setup
class CustomEnv {
  final Map<String, String> _configs = {};

  void set(String key, String value) => _configs[key] = value;
  String? get(String key) => _configs[key];
}
''');
      metadata['generatedDirectories'].add('lib/core/config');
      metadata['generatedFiles'].add('lib/core/config/custom_env.dart');
    }

    return metadata;
  }
}

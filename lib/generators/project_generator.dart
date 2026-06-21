import 'dart:io';

/// Responsibility:
/// Generates the initial project architecture layout.
/// Scaffolds folders, creates forge.yaml, injects packages into pubspec.yaml, and adds core/ directories.

class ProjectGenerator {
  // TODO: Add methods to edit pubspec.yaml and add dependencies.
  // TODO: Add methods to create lib/core/ directories (network, exceptions, router, di, theme).
  // TODO: Add methods to generate environmental files (.env.dev, .env.staging, .env.prod).
  // TODO: Add methods to create main entry points (main_dev.dart, main_staging.dart, main_prod.dart).

  Future<void> injectArchitectureFolders(String projectPath) async {
    final directories = [
      'lib/app/config',
      'lib/app/routes',
      'lib/core/network',
      'lib/core/exceptions',
      'lib/core/storage',
      'lib/core/services',
      'lib/core/utils',
      'lib/features',
    ];

    final baseDir = projectPath.endsWith('/')
        ? projectPath.substring(0, projectPath.length - 1)
        : projectPath;

    for (final dirPath in directories) {
      final dir = Directory('$baseDir/$dirPath');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    }
  }

  Future<void> scaffoldAppException(String projectPath) async {
    final baseDir = projectPath.endsWith('/')
        ? projectPath.substring(0, projectPath.length - 1)
        : projectPath;

    final file = File('$baseDir/lib/core/exceptions/app_exception.dart');
    if (!await file.exists()) {
      await file.parent.create(recursive: true);
      await file.writeAsString('''
// Responsibility:
// Application level exception container.

sealed class AppException implements Exception {
  final String message;

  const AppException(this.message);
}

class UnknownException extends AppException {
  const UnknownException(super.message);
}
''');
    }
  }

  Future<void> scaffoldApiResult(String projectPath) async {
    final baseDir = projectPath.endsWith('/')
        ? projectPath.substring(0, projectPath.length - 1)
        : projectPath;

    final file = File('$baseDir/lib/core/network/api_result.dart');
    if (!await file.exists()) {
      await file.parent.create(recursive: true);
      await file.writeAsString('''
import '../exceptions/app_exception.dart';

// Responsibility:
// Represents functional API response outputs.

sealed class ApiResult<T> {
  const ApiResult();
}

class Success<T> extends ApiResult<T> {
  final T data;

  const Success(this.data);
}

class Failure<T> extends ApiResult<T> {
  final AppException exception;

  const Failure(this.exception);
}
''');
    }
  }

  Future<void> scaffoldExceptionMapper(String projectPath) async {
    final baseDir = projectPath.endsWith('/')
        ? projectPath.substring(0, projectPath.length - 1)
        : projectPath;

    final file = File('$baseDir/lib/core/exceptions/exception_mapper.dart');
    if (!await file.exists()) {
      await file.parent.create(recursive: true);
      await file.writeAsString('''
import 'app_exception.dart';

// Responsibility:
// Maps exceptions to standard AppExceptions.

class ExceptionMapper {
  static AppException map(dynamic exception) {
    return UnknownException(exception.toString());
  }
}
''');
    }
  }

  Future<void> scaffoldDioClient(String projectPath) async {
    final baseDir = projectPath.endsWith('/')
        ? projectPath.substring(0, projectPath.length - 1)
        : projectPath;

    final file = File('$baseDir/lib/core/network/dio_client.dart');
    if (!await file.exists()) {
      await file.parent.create(recursive: true);
      await file.writeAsString('''
import 'package:dio/dio.dart';

// Responsibility:
// Configures and holds the concrete Dio HTTP client instance.

class DioClient {
  final Dio _dio;

  DioClient(this._dio);

  Dio get dio => _dio;
}
''');
    }
  }

  Future<void> installDependencies(String projectPath) async {
    final dependencies = [
      'dio',
    ];

    final baseDir = projectPath.endsWith('/')
        ? projectPath.substring(0, projectPath.length - 1)
        : projectPath;

    final result = await Process.run(
      'flutter',
      ['pub', 'add', ...dependencies],
      workingDirectory: baseDir,
    );

    if (result.exitCode != 0) {
      throw ProcessException(
        'flutter',
        ['pub', 'add', ...dependencies],
        result.stderr as String,
        result.exitCode,
      );
    }
  }

  Future<void> generate({
    required String projectName,
    required String path,
    required String stateManagement,
    required String router,
  }) async {
    // TODO: Write forge.yaml config.
    // TODO: Scaffold root core folders.
    // TODO: Create initial entrypoint files and loading mechanisms.
  }
}

import 'dart:io';
import '../models/final_project_blueprint.dart';

class SessionGenerator {
  bool supports(String sessionStrategy) {
    final normalized = sessionStrategy.trim().toLowerCase();
    return normalized == 'persistent session' ||
        normalized == 'persistent session architecture' ||
        normalized == 'persistent session strategy' ||
        normalized == 'secure storage' ||
        normalized == 'shared preferences' ||
        normalized == 'memory session';
  }

  Future<Map<String, dynamic>> generate(
    String projectPath,
    FinalProjectBlueprint blueprint,
  ) async {
    final sessionStrategy = blueprint.sessionStrategy;
    if (!supports(sessionStrategy)) {
      throw ArgumentError('Unsupported session strategy: $sessionStrategy');
    }

    final normalized = sessionStrategy.trim().toLowerCase();
    final metadata = <String, dynamic>{
      'sessionStrategy': sessionStrategy,
      'generatedDirectories': <String>[],
      'generatedFiles': <String>[],
      'packagesToAdd': <String>[],
    };

    final sessionDir = Directory('$projectPath/lib/core/session');

    if (normalized == 'persistent session' ||
        normalized == 'persistent session architecture' ||
        normalized == 'persistent session strategy') {
      if (!await sessionDir.exists()) {
        await sessionDir.create(recursive: true);
      }
      final file = File('${sessionDir.path}/session_manager.dart');
      await file.writeAsString('''
// Session: Persistent Session Manager
class SessionManager {
  // Secure & persistent session configuration
}
''');
      metadata['generatedDirectories'].add('lib/core/session');
      metadata['generatedFiles'].add('lib/core/session/session_manager.dart');
      metadata['packagesToAdd'].add('flutter_secure_storage');
    } else if (normalized == 'secure storage') {
      if (!await sessionDir.exists()) {
        await sessionDir.create(recursive: true);
      }
      final file = File('${sessionDir.path}/secure_storage_service.dart');
      await file.writeAsString('''
// Session: Secure Storage Service
class SecureStorageService {
  // Encrypted storage implementation details
}
''');
      metadata['generatedDirectories'].add('lib/core/session');
      metadata['generatedFiles'].add('lib/core/session/secure_storage_service.dart');
      metadata['packagesToAdd'].add('flutter_secure_storage');
    } else if (normalized == 'shared preferences') {
      if (!await sessionDir.exists()) {
        await sessionDir.create(recursive: true);
      }
      final file = File('${sessionDir.path}/preferences_service.dart');
      await file.writeAsString('''
// Session: Shared Preferences Service
class PreferencesService {
  // Key-value local storage setup
}
''');
      metadata['generatedDirectories'].add('lib/core/session');
      metadata['generatedFiles'].add('lib/core/session/preferences_service.dart');
      metadata['packagesToAdd'].add('shared_preferences');
    } else if (normalized == 'memory session') {
      if (!await sessionDir.exists()) {
        await sessionDir.create(recursive: true);
      }
      final file = File('${sessionDir.path}/memory_session_store.dart');
      await file.writeAsString('''
// Session: In-Memory Session Store
class MemorySessionStore {
  // Non-persistent runtime memory storage
}
''');
      metadata['generatedDirectories'].add('lib/core/session');
      metadata['generatedFiles'].add('lib/core/session/memory_session_store.dart');
    }

    return metadata;
  }
}

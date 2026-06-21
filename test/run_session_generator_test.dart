import 'dart:io';
import 'package:ironship/models/final_project_blueprint.dart';
import 'package:ironship/generators/session_generator.dart';

void main() async {
  print('Starting Session Generator Verification tests...\n');

  final generator = SessionGenerator();
  final tempDir = 'test_session_gen_project';

  // Helper cleanup method
  Future<void> cleanup() async {
    final dir = Directory(tempDir);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  await cleanup();

  // Test 1: Persistent Session generation
  print('1. Verifying Persistent Session generation...');
  final persistentBlueprint = const FinalProjectBlueprint(
    stateManagement: 'Riverpod',
    routing: 'Go Router',
    sessionStrategy: 'Persistent Session',
    environmentStrategy: 'Environment Configuration',
  );

  final persistentMeta = await generator.generate(tempDir, persistentBlueprint);
  print('Persistent Session Meta: $persistentMeta');

  final persistentFile = File('$tempDir/lib/core/session/session_manager.dart');
  if (!await persistentFile.exists()) {
    print('FAILED: Persistent Session file session_manager.dart was not created.');
    exit(1);
  }
  if (!persistentMeta['packagesToAdd'].contains('flutter_secure_storage')) {
    print('FAILED: Persistent Session package dependency metadata missing.');
    exit(1);
  }
  print('PASSED: Persistent Session generation successful.\n');
  await cleanup();

  // Test 2: Secure Storage generation
  print('2. Verifying Secure Storage generation...');
  final secureBlueprint = const FinalProjectBlueprint(
    stateManagement: 'Riverpod',
    routing: 'Go Router',
    sessionStrategy: 'Secure Storage',
    environmentStrategy: 'Environment Configuration',
  );

  final secureMeta = await generator.generate(tempDir, secureBlueprint);
  print('Secure Storage Meta: $secureMeta');

  final secureFile = File('$tempDir/lib/core/session/secure_storage_service.dart');
  if (!await secureFile.exists()) {
    print('FAILED: Secure Storage file secure_storage_service.dart was not created.');
    exit(1);
  }
  if (!secureMeta['packagesToAdd'].contains('flutter_secure_storage')) {
    print('FAILED: Secure Storage package dependency metadata missing.');
    exit(1);
  }
  print('PASSED: Secure Storage generation successful.\n');
  await cleanup();

  // Test 3: Shared Preferences generation
  print('3. Verifying Shared Preferences generation...');
  final prefsBlueprint = const FinalProjectBlueprint(
    stateManagement: 'Riverpod',
    routing: 'Go Router',
    sessionStrategy: 'Shared Preferences',
    environmentStrategy: 'Environment Configuration',
  );

  final prefsMeta = await generator.generate(tempDir, prefsBlueprint);
  print('Shared Preferences Meta: $prefsMeta');

  final prefsFile = File('$tempDir/lib/core/session/preferences_service.dart');
  if (!await prefsFile.exists()) {
    print('FAILED: Shared Preferences file preferences_service.dart was not created.');
    exit(1);
  }
  if (!prefsMeta['packagesToAdd'].contains('shared_preferences')) {
    print('FAILED: Shared Preferences package dependency metadata missing.');
    exit(1);
  }
  print('PASSED: Shared Preferences generation successful.\n');
  await cleanup();

  // Test 4: Memory Session generation
  print('4. Verifying Memory Session generation...');
  final memoryBlueprint = const FinalProjectBlueprint(
    stateManagement: 'Riverpod',
    routing: 'Go Router',
    sessionStrategy: 'Memory Session',
    environmentStrategy: 'Environment Configuration',
  );

  final memoryMeta = await generator.generate(tempDir, memoryBlueprint);
  print('Memory Session Meta: $memoryMeta');

  final memoryFile = File('$tempDir/lib/core/session/memory_session_store.dart');
  if (!await memoryFile.exists()) {
    print('FAILED: Memory Session file memory_session_store.dart was not created.');
    exit(1);
  }
  if (memoryMeta['packagesToAdd'].isNotEmpty) {
    print('FAILED: Memory Session should not add any external packages.');
    exit(1);
  }
  print('PASSED: Memory Session generation successful.\n');
  await cleanup();

  // Test 5: Divergent outputs based on inputs
  print('5. Verifying inputs generate divergent outputs...');
  if (secureMeta['packagesToAdd'].first == prefsMeta['packagesToAdd'].first) {
    print('FAILED: Generated dependency metadata did not diverge.');
    exit(1);
  }
  print('PASSED: Different inputs correctly result in different files and metadata.\n');

  // Test 6: Invalid support checks
  print('6. Verifying invalid inputs throw validation errors...');
  try {
    final invalidBlueprint = const FinalProjectBlueprint(
      stateManagement: 'Riverpod',
      routing: 'Go Router',
      sessionStrategy: 'Unsupported Session Strategy',
      environmentStrategy: 'Environment Configuration',
    );
    await generator.generate(tempDir, invalidBlueprint);
    print('FAILED: Unsupported session strategy option did not throw.');
    exit(1);
  } catch (e) {
    print('Caught expected unsupported session exception: $e');
    print('PASSED: Validation logic functions correctly.\n');
  }

  print('All Session Generator tests PASSED successfully!');
}

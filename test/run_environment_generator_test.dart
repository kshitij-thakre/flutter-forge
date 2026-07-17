import 'dart:io';
import 'package:ironship/models/final_project_blueprint.dart';
import 'package:ironship/generators/environment_generator.dart';

void main() async {
  print('Starting Environment Generator Verification tests...\n');

  final generator = EnvironmentGenerator();
  final tempDir = 'test_env_gen_project';

  // Helper cleanup method
  Future<void> cleanup() async {
    final dir = Directory(tempDir);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  await cleanup();

  // Test 1: Development Only generation
  print('1. Verifying Development Only generation...');
  final devOnlyBlueprint = const FinalProjectBlueprint(
    stateManagement: 'Riverpod',
    routing: 'Go Router',
    sessionStrategy: 'Persistent Session',
    environmentStrategy: 'Development Only',
  );

  final devOnlyMeta = await generator.generate(tempDir, devOnlyBlueprint);
  print('Development Only Meta: $devOnlyMeta');

  final devOnlyFile = File('$tempDir/lib/core/config/env.dart');
  if (!await devOnlyFile.exists()) {
    print('FAILED: Development Only file env.dart was not created.');
    exit(1);
  }
  print('PASSED: Development Only generation successful.\n');
  await cleanup();

  // Test 2: Dev + Production generation
  print('2. Verifying Dev + Production generation...');
  final devProdBlueprint = const FinalProjectBlueprint(
    stateManagement: 'Riverpod',
    routing: 'Go Router',
    sessionStrategy: 'Persistent Session',
    environmentStrategy: 'Dev + Production',
  );

  final devProdMeta = await generator.generate(tempDir, devProdBlueprint);
  print('Dev + Production Meta: $devProdMeta');

  final devProdEnvFile = File('$tempDir/lib/core/config/env.dart');
  final devProdDevFile = File('$tempDir/lib/core/config/env_dev.dart');
  final devProdProdFile = File('$tempDir/lib/core/config/env_prod.dart');
  if (!await devProdEnvFile.exists() ||
      !await devProdDevFile.exists() ||
      !await devProdProdFile.exists()) {
    print(
        'FAILED: Dev + Production configuration files were not fully created.');
    exit(1);
  }
  print('PASSED: Dev + Production generation successful.\n');
  await cleanup();

  // Test 3: Dev + Stage + Production generation
  print('3. Verifying Dev + Stage + Production generation...');
  final fullEnvBlueprint = const FinalProjectBlueprint(
    stateManagement: 'Riverpod',
    routing: 'Go Router',
    sessionStrategy: 'Persistent Session',
    environmentStrategy: 'Dev + Stage + Production',
  );

  final fullEnvMeta = await generator.generate(tempDir, fullEnvBlueprint);
  print('Dev + Stage + Production Meta: $fullEnvMeta');

  final fullEnvEnvFile = File('$tempDir/lib/core/config/env.dart');
  final fullEnvDevFile = File('$tempDir/lib/core/config/env_dev.dart');
  final fullEnvStageFile = File('$tempDir/lib/core/config/env_stage.dart');
  final fullEnvProdFile = File('$tempDir/lib/core/config/env_prod.dart');
  if (!await fullEnvEnvFile.exists() ||
      !await fullEnvDevFile.exists() ||
      !await fullEnvStageFile.exists() ||
      !await fullEnvProdFile.exists()) {
    print(
        'FAILED: Dev + Stage + Production configuration files were not fully created.');
    exit(1);
  }
  print('PASSED: Dev + Stage + Production generation successful.\n');
  await cleanup();

  // Test 4: Custom Environment generation
  print('4. Verifying Custom Environment generation...');
  final customEnvBlueprint = const FinalProjectBlueprint(
    stateManagement: 'Riverpod',
    routing: 'Go Router',
    sessionStrategy: 'Persistent Session',
    environmentStrategy: 'Custom Environment',
  );

  final customEnvMeta = await generator.generate(tempDir, customEnvBlueprint);
  print('Custom Environment Meta: $customEnvMeta');

  final customEnvFile = File('$tempDir/lib/core/config/custom_env.dart');
  if (!await customEnvFile.exists()) {
    print('FAILED: Custom Environment file custom_env.dart was not created.');
    exit(1);
  }
  print('PASSED: Custom Environment generation successful.\n');
  await cleanup();

  // Test 5: Divergent outputs based on inputs
  print('5. Verifying inputs generate divergent outputs...');
  if (devOnlyMeta['generatedFiles'].length ==
      fullEnvMeta['generatedFiles'].length) {
    print('FAILED: Generated configuration lists did not diverge in size.');
    exit(1);
  }
  print(
      'PASSED: Different inputs correctly result in different files and metadata.\n');

  // Test 6: Invalid support checks
  print('6. Verifying invalid inputs throw validation errors...');
  try {
    final invalidBlueprint = const FinalProjectBlueprint(
      stateManagement: 'Riverpod',
      routing: 'Go Router',
      sessionStrategy: 'Persistent Session',
      environmentStrategy: 'Unsupported Environment Setup',
    );
    await generator.generate(tempDir, invalidBlueprint);
    print('FAILED: Unsupported environment strategy option did not throw.');
    exit(1);
  } catch (e) {
    print('Caught expected unsupported environment exception: $e');
    print('PASSED: Validation logic functions correctly.\n');
  }

  print('All Environment Generator tests PASSED successfully!');
}

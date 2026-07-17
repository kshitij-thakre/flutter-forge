import 'dart:io';
import 'package:ironship/models/final_project_blueprint.dart';
import 'package:ironship/generators/state_management_generator.dart';

void main() async {
  print('Starting State Management Generator Verification tests...\n');

  final generator = StateManagementGenerator();
  final tempDir = 'test_state_gen_project';

  // Helper cleanup method
  Future<void> cleanup() async {
    final dir = Directory(tempDir);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  await cleanup();

  // Test 1: Blueprint consumption & Riverpod generation
  print('1. Verifying Riverpod generation...');
  final riverpodBlueprint = const FinalProjectBlueprint(
    stateManagement: 'Riverpod',
    routing: 'Go Router',
    sessionStrategy: 'Persistent Session',
    environmentStrategy: 'Environment Configuration',
  );

  final riverpodMeta = await generator.generate(tempDir, riverpodBlueprint);
  print('Riverpod Meta: $riverpodMeta');

  final riverpodFile = File('$tempDir/lib/core/state/provider_observer.dart');
  if (!await riverpodFile.exists()) {
    print('FAILED: Riverpod file provider_observer.dart was not created.');
    exit(1);
  }
  if (!riverpodMeta['packagesToAdd'].contains('flutter_riverpod')) {
    print('FAILED: Riverpod package dependency metadata missing.');
    exit(1);
  }
  print('PASSED: Riverpod generation successful.\n');
  await cleanup();

  // Test 2: Bloc generation
  print('2. Verifying Bloc generation...');
  final blocBlueprint = const FinalProjectBlueprint(
    stateManagement: 'Bloc',
    routing: 'Go Router',
    sessionStrategy: 'Persistent Session',
    environmentStrategy: 'Environment Configuration',
  );

  final blocMeta = await generator.generate(tempDir, blocBlueprint);
  print('Bloc Meta: $blocMeta');

  final blocFile = File('$tempDir/lib/core/state/bloc_observer.dart');
  if (!await blocFile.exists()) {
    print('FAILED: Bloc file bloc_observer.dart was not created.');
    exit(1);
  }
  print('PASSED: Bloc generation successful.\n');
  await cleanup();

  // Test 3: Provider generation
  print('3. Verifying Provider generation...');
  final providerBlueprint = const FinalProjectBlueprint(
    stateManagement: 'Provider',
    routing: 'Go Router',
    sessionStrategy: 'Persistent Session',
    environmentStrategy: 'Environment Configuration',
  );

  final providerMeta = await generator.generate(tempDir, providerBlueprint);
  print('Provider Meta: $providerMeta');

  final providerFile = File('$tempDir/lib/core/state/base_notifier.dart');
  if (!await providerFile.exists()) {
    print('FAILED: Provider file base_notifier.dart was not created.');
    exit(1);
  }
  print('PASSED: Provider generation successful.\n');
  await cleanup();

  // Test 4: GetX generation
  print('4. Verifying GetX generation...');
  final getxBlueprint = const FinalProjectBlueprint(
    stateManagement: 'GetX',
    routing: 'Go Router',
    sessionStrategy: 'Persistent Session',
    environmentStrategy: 'Environment Configuration',
  );

  final getxMeta = await generator.generate(tempDir, getxBlueprint);
  print('GetX Meta: $getxMeta');

  final getxFile = File('$tempDir/lib/core/state/base_controller.dart');
  if (!await getxFile.exists()) {
    print('FAILED: GetX file base_controller.dart was not created.');
    exit(1);
  }
  print('PASSED: GetX generation successful.\n');
  await cleanup();

  // Test 5: Different inputs generate different outputs
  print('5. Verifying inputs generate divergent outputs...');
  if (riverpodMeta['packagesToAdd'].first == blocMeta['packagesToAdd'].first) {
    print('FAILED: Generated dependency metadata did not diverge.');
    exit(1);
  }
  print(
      'PASSED: Different inputs correctly result in different files and metadata.\n');

  // Test 6: Invalid support checks
  print('6. Verifying invalid inputs throw validation errors...');
  try {
    final invalidBlueprint = const FinalProjectBlueprint(
      stateManagement: 'Unsupported State',
      routing: 'Go Router',
      sessionStrategy: 'Persistent Session',
      environmentStrategy: 'Environment Configuration',
    );
    await generator.generate(tempDir, invalidBlueprint);
    print('FAILED: Unsupported state management option did not throw.');
    exit(1);
  } catch (e) {
    print('Caught expected unsupported state exception: $e');
    print('PASSED: Validation logic functions correctly.\n');
  }

  print('All State Management Generator tests PASSED successfully!');
}

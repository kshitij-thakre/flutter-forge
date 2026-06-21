import 'dart:io';
import 'package:ironship/models/final_project_blueprint.dart';
import 'package:ironship/generators/router_generator.dart';

void main() async {
  print('Starting Router Generator Verification tests...\n');

  final generator = RouterGenerator();
  final tempDir = 'test_router_gen_project';

  // Helper cleanup method
  Future<void> cleanup() async {
    final dir = Directory(tempDir);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  await cleanup();

  // Test 1: Go Router generation
  print('1. Verifying Go Router generation...');
  final goRouterBlueprint = const FinalProjectBlueprint(
    stateManagement: 'Riverpod',
    routing: 'Go Router',
    sessionStrategy: 'Persistent Session',
    environmentStrategy: 'Environment Configuration',
  );

  final goRouterMeta = await generator.generate(tempDir, goRouterBlueprint);
  print('Go Router Meta: $goRouterMeta');

  final goRouterFile = File('$tempDir/lib/core/router/app_router.dart');
  if (!await goRouterFile.exists()) {
    print('FAILED: Go Router file app_router.dart was not created.');
    exit(1);
  }
  if (!goRouterMeta['packagesToAdd'].contains('go_router')) {
    print('FAILED: Go Router package dependency metadata missing.');
    exit(1);
  }
  print('PASSED: Go Router generation successful.\n');
  await cleanup();

  // Test 2: Navigation 2.0 generation
  print('2. Verifying Navigation 2.0 generation...');
  final navBlueprint = const FinalProjectBlueprint(
    stateManagement: 'Riverpod',
    routing: 'Navigation 2.0',
    sessionStrategy: 'Persistent Session',
    environmentStrategy: 'Environment Configuration',
  );

  final navMeta = await generator.generate(tempDir, navBlueprint);
  print('Navigation 2.0 Meta: $navMeta');

  final navFile = File('$tempDir/lib/core/router/router_delegate.dart');
  if (!await navFile.exists()) {
    print('FAILED: Navigation 2.0 file router_delegate.dart was not created.');
    exit(1);
  }
  if (navMeta['packagesToAdd'].isNotEmpty) {
    print('FAILED: Navigation 2.0 should not add any external packages.');
    exit(1);
  }
  print('PASSED: Navigation 2.0 generation successful.\n');
  await cleanup();

  // Test 3: Auto Route generation
  print('3. Verifying Auto Route generation...');
  final autoRouteBlueprint = const FinalProjectBlueprint(
    stateManagement: 'Riverpod',
    routing: 'Auto Route',
    sessionStrategy: 'Persistent Session',
    environmentStrategy: 'Environment Configuration',
  );

  final autoRouteMeta = await generator.generate(tempDir, autoRouteBlueprint);
  print('Auto Route Meta: $autoRouteMeta');

  final autoRouteFile = File('$tempDir/lib/core/router/app_router.dart');
  if (!await autoRouteFile.exists()) {
    print('FAILED: Auto Route file app_router.dart was not created.');
    exit(1);
  }
  if (!autoRouteMeta['packagesToAdd'].contains('auto_route')) {
    print('FAILED: Auto Route package dependency metadata missing.');
    exit(1);
  }
  print('PASSED: Auto Route generation successful.\n');
  await cleanup();

  // Test 4: Beamer generation
  print('4. Verifying Beamer generation...');
  final beamerBlueprint = const FinalProjectBlueprint(
    stateManagement: 'Riverpod',
    routing: 'Beamer',
    sessionStrategy: 'Persistent Session',
    environmentStrategy: 'Environment Configuration',
  );

  final beamerMeta = await generator.generate(tempDir, beamerBlueprint);
  print('Beamer Meta: $beamerMeta');

  final beamerFile = File('$tempDir/lib/core/router/router_location.dart');
  if (!await beamerFile.exists()) {
    print('FAILED: Beamer file router_location.dart was not created.');
    exit(1);
  }
  if (!beamerMeta['packagesToAdd'].contains('beamer')) {
    print('FAILED: Beamer package dependency metadata missing.');
    exit(1);
  }
  print('PASSED: Beamer generation successful.\n');
  await cleanup();

  // Test 5: Divergent outputs based on inputs
  print('5. Verifying inputs generate divergent outputs...');
  if (goRouterMeta['packagesToAdd'].first == beamerMeta['packagesToAdd'].first) {
    print('FAILED: Generated dependency metadata did not diverge.');
    exit(1);
  }
  print('PASSED: Different inputs correctly result in different files and metadata.\n');

  // Test 6: Invalid support checks
  print('6. Verifying invalid inputs throw validation errors...');
  try {
    final invalidBlueprint = const FinalProjectBlueprint(
      stateManagement: 'Riverpod',
      routing: 'Unsupported Router',
      sessionStrategy: 'Persistent Session',
      environmentStrategy: 'Environment Configuration',
    );
    await generator.generate(tempDir, invalidBlueprint);
    print('FAILED: Unsupported routing option did not throw.');
    exit(1);
  } catch (e) {
    print('Caught expected unsupported router exception: $e');
    print('PASSED: Validation logic functions correctly.\n');
  }

  print('All Router Generator tests PASSED successfully!');
}

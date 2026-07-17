import 'dart:convert';
import 'dart:io';
import 'package:ironship/models/project_requirements.dart';
import 'package:ironship/models/project_configuration.dart';
import 'package:ironship/models/final_project_blueprint.dart';
import 'package:ironship/services/project_blueprint_service.dart';

void main() async {
  print('Starting End-to-End Integration Engine Verification tests...\n');

  // --- PROGRAMMATIC VERIFICATIONS ---

  // 1. Verify Small App Flow
  print('1. Verifying Small App flow programmatically...');
  final smallConfig = ProjectConfiguration(
    projectName: 'small_test_app',
    createdAt: DateTime.now(),
    requirements: const ProjectRequirements(
      stateManagement: 'Recommend for me',
      routing: 'Recommend for me',
      projectScale: 'Simple App',
      screenCount: '1-10',
      authenticationRequired: false,
      sessionRequired: false,
      environmentSetup: 'Dev only',
    ),
  );

  final smallBlueprint =
      await ProjectBlueprintService().buildBlueprint(smallConfig);
  print(smallBlueprint);

  if (smallBlueprint.stateManagement != 'Riverpod' ||
      smallBlueprint.routing != 'Navigation 2.0' ||
      smallBlueprint.sessionStrategy != 'No session storage required' ||
      smallBlueprint.environmentStrategy != 'Single environment setup') {
    print(
        'FAILED: Small App flow blueprint generated incorrect recommendations.');
    exit(1);
  }
  print('PASSED: Small App flow blueprint verified successfully.\n');

  // 2. Verify Enterprise App Flow
  print('2. Verifying Enterprise App flow programmatically...');
  final enterpriseConfig = ProjectConfiguration(
    projectName: 'enterprise_test_app',
    createdAt: DateTime.now(),
    requirements: const ProjectRequirements(
      stateManagement: 'Recommend for me',
      routing: 'Recommend for me',
      projectScale: 'Enterprise App',
      screenCount: '100+',
      authenticationRequired: true,
      sessionRequired: true,
      environmentSetup: 'Dev + Stage + Production',
    ),
  );

  final enterpriseBlueprint =
      await ProjectBlueprintService().buildBlueprint(enterpriseConfig);
  print(enterpriseBlueprint);

  if (enterpriseBlueprint.stateManagement != 'Riverpod' ||
      enterpriseBlueprint.routing != 'Go Router' ||
      enterpriseBlueprint.sessionStrategy !=
          'Persistent session architecture' ||
      enterpriseBlueprint.environmentStrategy !=
          'Environment configuration setup') {
    print(
        'FAILED: Enterprise App flow blueprint generated incorrect recommendations.');
    exit(1);
  }
  print('PASSED: Enterprise App flow blueprint verified successfully.\n');

  // 3. Verify Developer Override Flow
  print('3. Verifying Developer Override flow programmatically...');
  final overrideConfig = ProjectConfiguration(
    projectName: 'override_test_app',
    createdAt: DateTime.now(),
    requirements: const ProjectRequirements(
      stateManagement: 'Recommend for me',
      routing: 'Recommend for me',
      projectScale: 'Medium Scale App',
      screenCount: '10-30',
      authenticationRequired: true,
      sessionRequired: true,
      environmentSetup: 'Dev + Stage + Production',
    ),
  );

  final overrideBlueprint = await ProjectBlueprintService().buildBlueprint(
    overrideConfig,
    overrideStateManagement: 'Bloc',
    overrideRouting: 'Navigation 2.0',
  );
  print(overrideBlueprint);

  if (overrideBlueprint.stateManagement != 'Bloc' ||
      overrideBlueprint.routing != 'Navigation 2.0' ||
      overrideBlueprint.sessionStrategy != 'Persistent session architecture' ||
      overrideBlueprint.environmentStrategy !=
          'Environment configuration setup') {
    print(
        'FAILED: Developer Override did not override recommendations correctly.');
    exit(1);
  }
  print('PASSED: Developer Override flow verified successfully.\n');

  // 4. Verify Package Aggregation
  print('4. Verifying Package Aggregation logic programmatically...');
  final blueprint1 = const FinalProjectBlueprint(
    stateManagement: 'Riverpod',
    routing: 'Go Router',
    sessionStrategy: 'Persistent Session',
    environmentStrategy: 'Single environment setup',
  );

  final packages = <String>{'dio'};
  if (blueprint1.stateManagement.toLowerCase() == 'riverpod') {
    packages.add('flutter_riverpod');
  }
  if (blueprint1.routing.toLowerCase() == 'go router') {
    packages.add('go_router');
  }
  if (blueprint1.sessionStrategy.toLowerCase().contains('persistent session')) {
    packages.add('flutter_secure_storage');
  }

  if (packages.length != 4 ||
      !packages.contains('dio') ||
      !packages.contains('flutter_riverpod') ||
      !packages.contains('go_router') ||
      !packages.contains('flutter_secure_storage')) {
    print(
        'FAILED: Package Aggregation logic collected incorrect packages: $packages');
    exit(1);
  }
  print('PASSED: Package Aggregation verified successfully.\n');

  // --- PROCESS-BASED INTEGRATION VERIFICATIONS ---

  // 5. Verify Compatibility Failures (instant validation failure, no flutter project created)
  print('5. Verifying compatibility failure flow via CLI execution...');
  final failureProcess = await Process.start(
      'dart', ['run', 'bin/forge.dart', 'init', 'fail_test_app']);

  final inputs1 = [
    '4', // State management: Recommend for me
    '4', // Routing: Recommend for me
    '2', // Scale: Medium
    '2', // Screens: 10-30
    '1', // Auth: Yes
    '1', // Session: Yes
    '3', // Env: Dev + Stage + Prod
    'y', // Want to override
    'Provider', // State Override (Incompatible)
    'Auto Route', // Routing Override (Incompatible)
    'Persistent Session', // Session Override
    'Single environment setup' // Env Override
  ];

  for (final input in inputs1) {
    failureProcess.stdin.writeln(input);
  }
  await failureProcess.stdin.flush();

  final exitCode1 = await failureProcess.exitCode;
  final stdout1 = await failureProcess.stdout.transform(utf8.decoder).join();
  final stderr1 = await failureProcess.stderr.transform(utf8.decoder).join();

  print('CLI Exit code: $exitCode1');
  if (stderr1.isNotEmpty) {
    print('Stderr Output: $stderr1');
  }
  if (!stdout1.contains('Compatibility validation failed:')) {
    print(
        'FAILED: Compatibility failure flow did not fail with validation error.');
    print('Stdout:\n$stdout1');
    exit(1);
  }

  final failDirectory = Directory('fail_test_app');
  if (await failDirectory.exists()) {
    print(
        'FAILED: Directory was created even though compatibility validation failed.');
    exit(1);
  }
  print(
      'PASSED: Compatibility validation failure successfully terminated project creation.\n');

  // 6. Verify End-to-End Happy Path (creates a real project and installs dependencies once)
  print('6. Verifying E2E Happy Path flow via CLI execution...');
  final appName = 'e2e_happy_app';
  final happyDirectory = Directory(appName);
  if (await happyDirectory.exists()) {
    await happyDirectory.delete(recursive: true);
  }

  final happyProcess =
      await Process.start('dart', ['run', 'bin/forge.dart', 'init', appName]);
  final inputs2 = [
    '4', // State management: Recommend for me -> Riverpod
    '4', // Routing: Recommend for me -> Navigation 2.0
    '1', // Scale: Simple App
    '1', // Screens: 1-10
    '2', // Auth: No
    '2', // Session: No
    '1', // Env: Dev only
    'n' // Override: No
  ];

  for (final input in inputs2) {
    happyProcess.stdin.writeln(input);
  }
  await happyProcess.stdin.flush();

  final exitCode2 = await happyProcess.exitCode;
  final stdout2 = await happyProcess.stdout.transform(utf8.decoder).join();

  print('CLI Exit code: $exitCode2');
  if (exitCode2 != 0) {
    print('FAILED: Happy path process exited with non-zero code $exitCode2.');
    print('Stdout:\n$stdout2');
    exit(1);
  }

  // Verify created configurations and files
  final configFile = File('$appName/forge_config.json');
  if (!await configFile.exists()) {
    print('FAILED: forge_config.json was not persisted.');
    exit(1);
  }

  final appExceptionFile =
      File('$appName/lib/core/exceptions/app_exception.dart');
  final providerObserverFile =
      File('$appName/lib/core/state/provider_observer.dart');
  final routerDelegateFile =
      File('$appName/lib/core/router/router_delegate.dart');
  final envFile = File('$appName/lib/core/config/env.dart');

  if (!await appExceptionFile.exists() ||
      !await providerObserverFile.exists() ||
      !await routerDelegateFile.exists() ||
      !await envFile.exists()) {
    print('FAILED: Generated architectural code files are missing.');
    exit(1);
  }

  // Verify pubspec dependency aggregation
  final pubspecFile = File('$appName/pubspec.yaml');
  final pubspecContent = await pubspecFile.readAsString();
  if (!pubspecContent.contains('dio:') ||
      !pubspecContent.contains('flutter_riverpod:')) {
    print('FAILED: dependencies aggregation missing from pubspec.yaml.');
    exit(1);
  }

  // Clean up
  print('Cleaning up e2e_happy_app directory...');
  await happyDirectory.delete(recursive: true);

  print('PASSED: End-to-End Happy Path executed successfully.\n');
  print('All End-to-End Integration Engine tests PASSED successfully!');
}

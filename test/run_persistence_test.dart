import 'dart:io';
import 'package:ironship/models/project_requirements.dart';
import 'package:ironship/models/project_configuration.dart';
import 'package:ironship/services/configuration_service.dart';

void main() async {
  print('Starting Requirements Persistence Layer Verification tests...\n');

  final service = ConfigurationService();
  final requirements = ProjectRequirements(
    stateManagement: 'Bloc',
    routing: 'Go Router',
    projectScale: 'Medium Scale App',
    screenCount: '10-30',
    authenticationRequired: true,
    sessionRequired: true,
    environmentSetup: 'Dev + Stage + Production',
  );

  final originalConfig = ProjectConfiguration(
    projectName: 'my_test_app',
    createdAt: DateTime.utc(2026, 6, 21, 12, 0, 0),
    requirements: requirements,
  );

  // 1. Verify JSON generation
  print('1. Verifying JSON generation...');
  final json = originalConfig.toJson();
  print('Generated JSON:\n$json\n');
  if (json['projectName'] != 'my_test_app' ||
      json['requirements']['stateManagement'] != 'Bloc') {
    print('FAILED: JSON generation failed validation.');
    exit(1);
  }
  print('PASSED: JSON generation verified.\n');

  // 2. Verify Save functionality
  final tempFile = 'test_forge_config.json';
  print('2. Verifying Save functionality (saving to $tempFile)...');
  await service.save(tempFile, originalConfig);
  final file = File(tempFile);
  if (!await file.exists()) {
    print('FAILED: Configuration file not created.');
    exit(1);
  }
  print('PASSED: Configuration saved.\n');

  // 3. Verify Load functionality
  print('3. Verifying Load functionality...');
  final loadedConfig = await service.load(tempFile);
  if (loadedConfig.projectName != originalConfig.projectName ||
      loadedConfig.createdAt.toIso8601String() != originalConfig.createdAt.toIso8601String() ||
      loadedConfig.requirements.stateManagement != originalConfig.requirements.stateManagement) {
    print('FAILED: Loaded configuration does not match original.');
    exit(1);
  }
  print('PASSED: Configuration loaded successfully with matching values.\n');

  // 4. Verify Validation functionality
  print('4. Verifying Validation functionality...');
  final isValid = service.validate(loadedConfig);
  if (!isValid) {
    print('FAILED: Valid configuration marked as invalid.');
    exit(1);
  }

  // Create invalid config
  final invalidConfig = ProjectConfiguration(
    projectName: '  ',
    createdAt: DateTime.now(),
    requirements: requirements,
  );
  final isInvalid = !service.validate(invalidConfig);
  if (!isInvalid) {
    print('FAILED: Invalid configuration marked as valid.');
    exit(1);
  }
  print('PASSED: Validation functionality verified successfully.\n');

  // Clean up
  print('Cleaning up temporary configuration file...');
  if (await file.exists()) {
    await file.delete();
  }

  print('\nAll Persistence Verification tests PASSED successfully!');
}

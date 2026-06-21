import 'dart:io';
import 'package:ironship/models/project_requirements.dart';
import 'package:ironship/models/project_configuration.dart';
import 'package:ironship/models/final_project_blueprint.dart';
import 'package:ironship/services/project_blueprint_service.dart';

void main() async {
  print('Starting Final Project Blueprint Engine Verification tests...\n');

  final service = ProjectBlueprintService();

  final config = ProjectConfiguration(
    projectName: 'blueprint_test_app',
    createdAt: DateTime.now(),
    requirements: ProjectRequirements(
      stateManagement: 'Recommend for me',
      routing: 'Recommend for me',
      projectScale: 'Medium Scale App',
      screenCount: '10-30',
      authenticationRequired: true,
      sessionRequired: true,
      environmentSetup: 'Dev + Stage + Production',
    ),
  );

  // Test 1: Blueprint generation works (with accepted recommendations)
  print('1. Verifying blueprint generation with accepted recommendations...');
  final FinalProjectBlueprint blueprint = await service.buildBlueprint(config);
  print(blueprint);
  
  if (blueprint.stateManagement != 'Riverpod' ||
      blueprint.routing != 'Go Router' ||
      blueprint.sessionStrategy != 'Persistent session architecture' ||
      blueprint.environmentStrategy != 'Environment configuration setup') {
    print('FAILED: Blueprint generated does not match expected recommendations.');
    exit(1);
  }
  print('PASSED: Blueprint generation successfully completed.\n');

  // Test 2: Blueprint overrides work (with custom selections)
  print('2. Verifying custom overrides are applied...');
  final FinalProjectBlueprint overriddenBlueprint = await service.buildBlueprint(
    config,
    overrideStateManagement: 'Bloc',
    overrideRouting: 'Navigation 2.0',
  );
  print(overriddenBlueprint);
  
  if (overriddenBlueprint.stateManagement != 'Bloc' ||
      overriddenBlueprint.routing != 'Navigation 2.0' ||
      overriddenBlueprint.sessionStrategy != 'Persistent session architecture' ||
      overriddenBlueprint.environmentStrategy != 'Environment configuration setup') {
    print('FAILED: Custom overrides did not register or preserve default fallbacks.');
    exit(1);
  }
  print('PASSED: Custom overrides verified.\n');

  // Test 3: Incompatible custom selections throw validation errors
  print('3. Verifying incompatible developer overrides throw errors...');
  try {
    await service.buildBlueprint(
      config,
      overrideStateManagement: 'Provider', // Incompatible
      overrideRouting: 'Auto Route', // Incompatible
    );
    print('FAILED: Incompatible options did not throw an error.');
    exit(1);
  } catch (e) {
    print('Caught expected compatibility error: $e');
    print('PASSED: Compatibility validation throws on conflicts.\n');
  }

  // Test 4: Different inputs generate different blueprints
  print('4. Verifying different inputs generate different blueprints...');
  if (blueprint.stateManagement == overriddenBlueprint.stateManagement ||
      blueprint.routing == overriddenBlueprint.routing) {
    print('FAILED: Different inputs did not result in different blueprints.');
    exit(1);
  }
  print('PASSED: Blueprints successfully diverged based on input params.\n');

  print('All Final Project Blueprint Engine tests PASSED successfully!');
}

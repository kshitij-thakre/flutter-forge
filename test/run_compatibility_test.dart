import 'dart:io';
import 'package:ironship/models/technology_compatibility.dart';
import 'package:ironship/services/technology_compatibility_service.dart';

void main() {
  print('Starting Technology Compatibility Engine Verification tests...\n');

  final service = TechnologyCompatibilityService();

  // Test 1: Verification validation works (schema checks)
  print('1. Verifying schema validation...');
  final emptyConfig = TechnologyCompatibility(
    stateManagement: '  ',
    routing: 'Go Router',
    sessionStrategy: 'Persistent Session',
    environmentStrategy: 'Single environment setup',
  );
  if (service.validate(emptyConfig)) {
    print('FAILED: Blank stateManagement passed validation.');
    exit(1);
  }
  print('PASSED: Schema validation catches empty fields.\n');

  // Test 2: Compatible combinations pass
  print('2. Verifying compatible combinations pass...');
  final validConfig1 = TechnologyCompatibility(
    stateManagement: 'Riverpod',
    routing: 'Go Router',
    sessionStrategy: 'Persistent Session',
    environmentStrategy: 'Environment Configuration',
    projectScale: 'Enterprise',
  );
  final validConfig2 = TechnologyCompatibility(
    stateManagement: 'Bloc',
    routing: 'Navigation 2.0',
    sessionStrategy: 'No session storage required',
    environmentStrategy: 'Single environment setup',
    projectScale: 'Small',
  );

  if (!service.isCompatible(validConfig1)) {
    print('FAILED: Valid Riverpod + Go Router config flagged incompatible.');
    print('Conflicts: ${service.getConflicts(validConfig1)}');
    exit(1);
  }
  if (!service.isCompatible(validConfig2)) {
    print('FAILED: Valid Bloc + Navigation 2.0 config flagged incompatible.');
    print('Conflicts: ${service.getConflicts(validConfig2)}');
    exit(1);
  }
  print('PASSED: Compatible combinations passed successfully.\n');

  // Test 3: Invalid combinations fail & Conflict detection works
  print('3. Verifying invalid combinations fail and conflicts are detected...');

  // Riverpod + incompatible routing (e.g. Auto Route)
  final invalidRouteConfig = TechnologyCompatibility(
    stateManagement: 'Riverpod',
    routing: 'Auto Route',
    sessionStrategy: 'No session storage required',
    environmentStrategy: 'Single environment setup',
  );
  final routeConflicts = service.getConflicts(invalidRouteConfig);
  print('Detected Routing Conflicts: $routeConflicts');
  if (service.isCompatible(invalidRouteConfig) || routeConflicts.isEmpty) {
    print('FAILED: Invalid routing did not generate conflicts.');
    exit(1);
  }

  // Persistent session + incompatible state management (e.g. Provider)
  final invalidSessionConfig = TechnologyCompatibility(
    stateManagement: 'Provider',
    routing: 'Go Router',
    sessionStrategy: 'Persistent Session',
    environmentStrategy: 'Single environment setup',
  );
  final sessionConflicts = service.getConflicts(invalidSessionConfig);
  print('Detected Session Conflicts: $sessionConflicts');
  if (service.isCompatible(invalidSessionConfig) || sessionConflicts.isEmpty) {
    print('FAILED: Incompatible session + state did not generate conflicts.');
    exit(1);
  }

  // Environment Configuration + incompatible scale (e.g. Custom)
  final invalidScaleConfig = TechnologyCompatibility(
    stateManagement: 'Bloc',
    routing: 'Go Router',
    sessionStrategy: 'Persistent Session',
    environmentStrategy: 'Environment Configuration',
    projectScale: 'Custom Scale',
  );
  final scaleConflicts = service.getConflicts(invalidScaleConfig);
  print('Detected Scale Conflicts: $scaleConflicts');
  if (service.isCompatible(invalidScaleConfig) || scaleConflicts.isEmpty) {
    print('FAILED: Incompatible scale setup did not generate conflicts.');
    exit(1);
  }
  print('PASSED: Conflict detection and compatibility failures verified.\n');

  // Test 4: Different combinations generate different results
  print('4. Verifying different combinations generate different results...');
  if (routeConflicts.join() == sessionConflicts.join()) {
    print(
        'FAILED: Different invalid combinations generated identical conflicts.');
    exit(1);
  }
  print('PASSED: Divergent combinations produce unique conflict lists.\n');

  print('All Technology Compatibility Engine tests PASSED successfully!');
}

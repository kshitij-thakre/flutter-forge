import 'dart:io';
import 'package:ironship/models/architecture_recommendation.dart';
import 'package:ironship/models/developer_selection.dart';
import 'package:ironship/services/developer_selection_service.dart';

void main() {
  print('Starting Developer Selection Override Engine Verification tests...\n');

  final service = DeveloperSelectionService();

  final recommendation = const ArchitectureRecommendation(
    recommendedStateManagement: 'Riverpod',
    alternativeStateManagement: 'Bloc',
    recommendedRouting: 'Go Router',
    sessionStrategy: 'Persistent Session',
    environmentStrategy: 'Environment Configuration',
  );

  // Test 1: Recommendation acceptance works
  print('1. Verifying recommendation acceptance...');
  final DeveloperSelection accepted = service.accept(recommendation);
  print(accepted);
  if (accepted.stateManagement != 'Riverpod' ||
      accepted.routing != 'Go Router' ||
      accepted.sessionStrategy != 'Persistent Session' ||
      accepted.environmentStrategy != 'Environment Configuration') {
    print('FAILED: Accepted selections do not match recommendations.');
    exit(1);
  }
  print('PASSED: Recommendation acceptance matches recommendations.\n');

  // Test 2: Recommendation override works & Final selection generation works
  print('2. Verifying recommendation overrides and final selection generation...');
  final DeveloperSelection overridden = service.overrideSelection(
    recommendation,
    stateManagement: 'Bloc',
    routing: 'Navigation 2.0',
  );
  print(overridden);
  if (overridden.stateManagement != 'Bloc' ||
      overridden.routing != 'Navigation 2.0' ||
      overridden.sessionStrategy != 'Persistent Session' ||
      overridden.environmentStrategy != 'Environment Configuration') {
    print('FAILED: Overridden selections did not register overrides or fallback properly.');
    exit(1);
  }
  print('PASSED: Recommendation overrides working with correct fallbacks.\n');

  // Test 3: Different selections generate different outputs
  print('3. Verifying different selections generate different outputs...');
  if (accepted.stateManagement == overridden.stateManagement ||
      accepted.routing == overridden.routing) {
    print('FAILED: Accepted and overridden selections returned identical outputs.');
    exit(1);
  }
  print('PASSED: Selection outputs successfully diverged.\n');

  print('All Developer Selection Override Engine tests PASSED successfully!');
}

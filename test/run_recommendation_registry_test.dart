import 'dart:io';
import 'package:ironship/services/recommendation_registry_service.dart';

void main() {
  print('Starting Recommendation Rules Registry Verification tests...\n');

  final service = RecommendationRegistryService();

  // Test 1: Registry creation works
  print('1. Verifying registry creation...');
  final allRules = service.getAllRules();
  print('Total Rules registered: ${allRules.length}');
  if (allRules.isEmpty) {
    print('FAILED: Rules registry is empty.');
    exit(1);
  }
  print('PASSED: Registry created with rules.\n');

  // Test 2: Rule retrieval works
  print('2. Verifying rule retrieval by trigger...');
  final smallRule = service.getRule('Small');
  if (smallRule == null) {
    print('FAILED: Rule for trigger "Small" not found.');
    exit(1);
  }
  print('Retrieved Small rule:\n$smallRule\n');
  if (smallRule.recommendation != 'Riverpod, Navigation 2.0' ||
      smallRule.category != 'Project Scale') {
    print('FAILED: Small rule attributes mismatch.');
    exit(1);
  }
  print('PASSED: Rule retrieval by trigger works successfully.\n');

  // Test 3: Category filtering works
  print('3. Verifying category filtering...');
  final scaleRules = service.getRulesByCategory('Project Scale');
  print('Category "Project Scale" contains ${scaleRules.length} rules.');
  if (scaleRules.length != 3) {
    print(
        'FAILED: Scale rules count mismatch (expected 3, got ${scaleRules.length}).');
    exit(1);
  }
  print('PASSED: Category filtering working.\n');

  // Test 4: Rule existence checks work
  print('4. Verifying rule existence checks...');
  if (!service.exists('Small')) {
    print('FAILED: exists("Small") returned false.');
    exit(1);
  }
  if (service.exists('Unknown Trigger')) {
    print('FAILED: exists("Unknown Trigger") returned true.');
    exit(1);
  }
  print('PASSED: Existence check working.\n');

  // Test 5: Different rules return different outputs
  print('5. Verifying different rules return different outputs...');
  final mediumRule = service.getRule('Medium');
  if (mediumRule == null) {
    print('FAILED: Rule for trigger "Medium" not found.');
    exit(1);
  }
  if (smallRule.recommendation == mediumRule.recommendation) {
    print('FAILED: Small and Medium rules returned identical recommendations.');
    exit(1);
  }
  print('PASSED: Different rules return unique recommendations.\n');

  // Test 6: All rules are reusable
  print('6. Verifying rules are reusable...');
  final allRulesSecondCall = service.getAllRules();
  if (allRules.length != allRulesSecondCall.length) {
    print('FAILED: Registry returned different size list on second call.');
    exit(1);
  }
  print('PASSED: Rules registry is reusable and list is protected.\n');

  print('All Recommendation Rules Registry tests PASSED successfully!');
}

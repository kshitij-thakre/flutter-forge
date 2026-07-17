import 'dart:io';
import 'package:ironship/models/project_requirements.dart';
import 'package:ironship/models/project_configuration.dart';
import 'package:ironship/services/architecture_recommendation_service.dart';

void main() {
  print('Starting Architecture Recommendation Engine tests...\n');

  final service = ArchitectureRecommendationService();

  // Test 1: Small Project Recommendations
  print('1. Testing Small Project recommendations...');
  final smallConfig = ProjectConfiguration(
    projectName: 'small_app',
    createdAt: DateTime.now(),
    requirements: ProjectRequirements(
      stateManagement: 'Recommend for me',
      routing: 'Recommend for me',
      projectScale: 'Simple App',
      screenCount: '1-10',
      authenticationRequired: false,
      sessionRequired: false,
      environmentSetup: 'Dev only',
    ),
  );
  final smallRec = service.recommend(smallConfig);
  print(smallRec);
  if (smallRec.recommendedRouting != 'Navigation 2.0' ||
      smallRec.recommendedStateManagement != 'Riverpod' ||
      smallRec.sessionStrategy != 'No session storage required' ||
      smallRec.environmentStrategy != 'Single environment setup') {
    print('FAILED: Small project recommendation mismatch.');
    exit(1);
  }
  print('PASSED: Small project recommendation matches criteria.\n');

  // Test 2: Medium Project Recommendations
  print('2. Testing Medium Project recommendations...');
  final mediumConfig = ProjectConfiguration(
    projectName: 'medium_app',
    createdAt: DateTime.now(),
    requirements: ProjectRequirements(
      stateManagement: 'Recommend for me',
      routing: 'Recommend for me',
      projectScale: 'Medium Scale App',
      screenCount: '10-30',
      authenticationRequired: false,
      sessionRequired: false,
      environmentSetup: 'Dev only',
    ),
  );
  final mediumRec = service.recommend(mediumConfig);
  print(mediumRec);
  if (mediumRec.recommendedRouting != 'Go Router' ||
      mediumRec.recommendedStateManagement != 'Riverpod' ||
      mediumRec.sessionStrategy != 'No session storage required') {
    print('FAILED: Medium project recommendation mismatch.');
    exit(1);
  }
  print('PASSED: Medium project recommendation matches criteria.\n');

  // Test 3: Large / Enterprise Project Recommendations
  print('3. Testing Enterprise Project recommendations...');
  final largeConfig = ProjectConfiguration(
    projectName: 'large_app',
    createdAt: DateTime.now(),
    requirements: ProjectRequirements(
      stateManagement: 'Recommend for me',
      routing: 'Recommend for me',
      projectScale: 'Enterprise App',
      screenCount: '100+',
      authenticationRequired: false,
      sessionRequired: false,
      environmentSetup: 'Dev only',
    ),
  );
  final largeRec = service.recommend(largeConfig);
  print(largeRec);
  if (largeRec.recommendedRouting != 'Go Router' ||
      largeRec.recommendedStateManagement != 'Riverpod') {
    print('FAILED: Enterprise project recommendation mismatch.');
    exit(1);
  }
  print('PASSED: Enterprise project recommendation matches criteria.\n');

  // Test 4: Auth Recommendation
  print('4. Testing Authentication recommendation...');
  final authConfig = ProjectConfiguration(
    projectName: 'auth_app',
    createdAt: DateTime.now(),
    requirements: ProjectRequirements(
      stateManagement: 'Recommend for me',
      routing: 'Recommend for me',
      projectScale: 'Simple App',
      screenCount: '1-10',
      authenticationRequired: true,
      sessionRequired: true,
      environmentSetup: 'Dev only',
    ),
  );
  final authRec = service.recommend(authConfig);
  print(authRec);
  if (authRec.sessionStrategy != 'Persistent session architecture') {
    print('FAILED: Auth persistent session recommendation mismatch.');
    exit(1);
  }
  print('PASSED: Authentication recommendation matches criteria.\n');

  // Test 5: Environment Recommendation
  print('5. Testing Environment setup recommendation...');
  final envConfig = ProjectConfiguration(
    projectName: 'env_app',
    createdAt: DateTime.now(),
    requirements: ProjectRequirements(
      stateManagement: 'Recommend for me',
      routing: 'Recommend for me',
      projectScale: 'Simple App',
      screenCount: '1-10',
      authenticationRequired: false,
      sessionRequired: false,
      environmentSetup: 'Dev + Stage + Production',
    ),
  );
  final envRec = service.recommend(envConfig);
  print(envRec);
  if (envRec.environmentStrategy != 'Environment configuration setup') {
    print('FAILED: Environment config strategy recommendation mismatch.');
    exit(1);
  }
  print('PASSED: Environment recommendation matches criteria.\n');

  // Test 6: Verify different inputs generate different recommendations
  print('6. Testing recommendation divergence...');
  if (smallRec.recommendedRouting == mediumRec.recommendedRouting &&
      smallConfig.requirements.projectScale !=
          mediumConfig.requirements.projectScale) {
    print('FAILED: Recommendations did not diverge.');
    exit(1);
  }
  print('PASSED: Recommendation divergence verified.\n');

  print('All Architecture Recommendation Engine tests PASSED successfully!');
}

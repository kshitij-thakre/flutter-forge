import '../models/project_configuration.dart';
import '../models/architecture_recommendation.dart';

class ArchitectureRecommendationService {
  ArchitectureRecommendation recommend(ProjectConfiguration config) {
    final reqs = config.requirements;

    // 1. State Management
    const recState = 'Riverpod';
    const altState = 'Bloc';

    // 2. Routing
    // Small projects: projectScale == 'Simple App' or screenCount == '1-10'
    // Medium/Large/Enterprise projects: use Go Router
    String recRouting = 'Go Router';
    if (reqs.projectScale == 'Simple App' || reqs.screenCount == '1-10') {
      recRouting = 'Navigation 2.0';
    }

    // 3. Session Strategy
    // Authentication required -> Recommend: Persistent session architecture
    String sessionStrategy = 'No session storage required';
    if (reqs.authenticationRequired) {
      sessionStrategy = 'Persistent session architecture';
    }

    // 4. Environment Strategy
    // Multiple environments required -> Recommend: Environment configuration setup
    String environmentStrategy = 'Single environment setup';
    if (reqs.environmentSetup == 'Dev + Stage' ||
        reqs.environmentSetup == 'Dev + Stage + Production') {
      environmentStrategy = 'Environment configuration setup';
    }

    return ArchitectureRecommendation(
      recommendedStateManagement: recState,
      alternativeStateManagement: altState,
      recommendedRouting: recRouting,
      sessionStrategy: sessionStrategy,
      environmentStrategy: environmentStrategy,
    );
  }
}

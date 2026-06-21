import '../models/architecture_recommendation.dart';
import '../models/developer_selection.dart';

class DeveloperSelectionService {
  DeveloperSelection accept(ArchitectureRecommendation recommendation) {
    return DeveloperSelection(
      stateManagement: recommendation.recommendedStateManagement,
      routing: recommendation.recommendedRouting,
      sessionStrategy: recommendation.sessionStrategy,
      environmentStrategy: recommendation.environmentStrategy,
    );
  }

  DeveloperSelection overrideSelection(
    ArchitectureRecommendation recommendation, {
    String? stateManagement,
    String? routing,
    String? sessionStrategy,
    String? environmentStrategy,
  }) {
    return DeveloperSelection(
      stateManagement: stateManagement ?? recommendation.recommendedStateManagement,
      routing: routing ?? recommendation.recommendedRouting,
      sessionStrategy: sessionStrategy ?? recommendation.sessionStrategy,
      environmentStrategy: environmentStrategy ?? recommendation.environmentStrategy,
    );
  }
}

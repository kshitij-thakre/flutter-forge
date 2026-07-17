import '../models/project_configuration.dart';
import '../models/technology_compatibility.dart';
import '../models/final_project_blueprint.dart';
import 'architecture_recommendation_service.dart';
import 'developer_selection_service.dart';
import 'technology_compatibility_service.dart';

class ProjectBlueprintService {
  final ArchitectureRecommendationService _recommendationService;
  final DeveloperSelectionService _selectionService;
  final TechnologyCompatibilityService _compatibilityService;

  ProjectBlueprintService({
    ArchitectureRecommendationService? recommendationService,
    DeveloperSelectionService? selectionService,
    TechnologyCompatibilityService? compatibilityService,
  })  : _recommendationService =
            recommendationService ?? ArchitectureRecommendationService(),
        _selectionService = selectionService ?? DeveloperSelectionService(),
        _compatibilityService =
            compatibilityService ?? TechnologyCompatibilityService();

  Future<FinalProjectBlueprint> buildBlueprint(
    ProjectConfiguration config, {
    String? overrideStateManagement,
    String? overrideRouting,
    String? overrideSessionStrategy,
    String? overrideEnvironmentStrategy,
  }) async {
    // 1. Get Recommendations from ProjectConfiguration
    final recommendation = _recommendationService.recommend(config);

    // 2. Developer Selection: accept or apply overrides
    final selection = _selectionService.overrideSelection(
      recommendation,
      stateManagement: overrideStateManagement,
      routing: overrideRouting,
      sessionStrategy: overrideSessionStrategy,
      environmentStrategy: overrideEnvironmentStrategy,
    );

    // 3. Compatibility Validation
    final compatibilityInput = TechnologyCompatibility(
      stateManagement: selection.stateManagement,
      routing: selection.routing,
      sessionStrategy: selection.sessionStrategy,
      environmentStrategy: selection.environmentStrategy,
      projectScale: config.requirements.projectScale,
    );

    final conflicts = _compatibilityService.getConflicts(compatibilityInput);
    if (conflicts.isNotEmpty) {
      throw ArgumentError(
          'Incompatible technology selection: ${conflicts.join(", ")}');
    }

    // 4. Return FinalProjectBlueprint
    return FinalProjectBlueprint(
      stateManagement: selection.stateManagement,
      routing: selection.routing,
      sessionStrategy: selection.sessionStrategy,
      environmentStrategy: selection.environmentStrategy,
    );
  }
}

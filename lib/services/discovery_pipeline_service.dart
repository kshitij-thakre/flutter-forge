import '../models/project_configuration.dart';
import 'questionnaire_service.dart';

class DiscoveryPipelineService {
  final QuestionnaireService _questionnaireService;

  DiscoveryPipelineService({QuestionnaireService? questionnaireService})
      : _questionnaireService = questionnaireService ?? QuestionnaireService();

  Future<ProjectConfiguration> execute(String projectName) async {
    final requirements = await _questionnaireService.run();

    return ProjectConfiguration(
      projectName: projectName,
      createdAt: DateTime.now(),
      requirements: requirements,
    );
  }
}

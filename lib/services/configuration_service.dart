import 'dart:convert';
import 'dart:io';
import '../models/project_configuration.dart';

class ConfigurationService {
  Future<void> save(String filePath, ProjectConfiguration config) async {
    final file = File(filePath);
    final encoder = JsonEncoder.withIndent('  ');
    final jsonString = encoder.convert(config.toJson());
    await file.writeAsString(jsonString);
  }

  Future<ProjectConfiguration> load(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException('Configuration file not found', filePath);
    }
    final content = await file.readAsString();
    final jsonMap = jsonDecode(content) as Map<String, dynamic>;
    return ProjectConfiguration.fromJson(jsonMap);
  }

  bool validate(ProjectConfiguration config) {
    if (config.projectName.trim().isEmpty) return false;
    
    final reqs = config.requirements;
    if (reqs.stateManagement.trim().isEmpty) return false;
    if (reqs.routing.trim().isEmpty) return false;
    if (reqs.projectScale.trim().isEmpty) return false;
    if (reqs.screenCount.trim().isEmpty) return false;
    if (reqs.environmentSetup.trim().isEmpty) return false;

    return true;
  }
}

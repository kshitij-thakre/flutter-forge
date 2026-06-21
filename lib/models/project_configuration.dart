import 'project_requirements.dart';

class ProjectConfiguration {
  final String projectName;
  final DateTime createdAt;
  final ProjectRequirements requirements;

  const ProjectConfiguration({
    required this.projectName,
    required this.createdAt,
    required this.requirements,
  });

  Map<String, dynamic> toJson() {
    return {
      'projectName': projectName,
      'createdAt': createdAt.toIso8601String(),
      'requirements': requirements.toJson(),
    };
  }

  factory ProjectConfiguration.fromJson(Map<String, dynamic> json) {
    return ProjectConfiguration(
      projectName: json['projectName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      requirements: ProjectRequirements.fromJson(
        json['requirements'] as Map<String, dynamic>,
      ),
    );
  }
}

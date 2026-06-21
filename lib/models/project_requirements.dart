class ProjectRequirements {
  final String stateManagement;
  final String routing;
  final String projectScale;
  final String screenCount;
  final bool authenticationRequired;
  final bool sessionRequired;
  final String environmentSetup;

  const ProjectRequirements({
    required this.stateManagement,
    required this.routing,
    required this.projectScale,
    required this.screenCount,
    required this.authenticationRequired,
    required this.sessionRequired,
    required this.environmentSetup,
  });

  Map<String, dynamic> toJson() {
    return {
      'stateManagement': stateManagement,
      'routing': routing,
      'projectScale': projectScale,
      'screenCount': screenCount,
      'authenticationRequired': authenticationRequired,
      'sessionRequired': sessionRequired,
      'environmentSetup': environmentSetup,
    };
  }

  factory ProjectRequirements.fromJson(Map<String, dynamic> json) {
    return ProjectRequirements(
      stateManagement: json['stateManagement'] as String,
      routing: json['routing'] as String,
      projectScale: json['projectScale'] as String,
      screenCount: json['screenCount'] as String,
      authenticationRequired: json['authenticationRequired'] as bool,
      sessionRequired: json['sessionRequired'] as bool,
      environmentSetup: json['environmentSetup'] as String,
    );
  }

  @override
  String toString() {
    return '''
====================================
Project Requirements Discovery
====================================
State Management:        $stateManagement
Routing Solution:        $routing
Project Scale:           $projectScale
Approx. Screen Count:    $screenCount
Authentication Required: ${authenticationRequired ? 'Yes' : 'No'}
Session Persistence:     ${sessionRequired ? 'Yes' : 'No'}
Environments Setup:      $environmentSetup
====================================''';
  }
}

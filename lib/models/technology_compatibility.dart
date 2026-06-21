class TechnologyCompatibility {
  final String stateManagement;
  final String routing;
  final String sessionStrategy;
  final String environmentStrategy;
  final String projectScale;

  const TechnologyCompatibility({
    required this.stateManagement,
    required this.routing,
    required this.sessionStrategy,
    required this.environmentStrategy,
    this.projectScale = 'Medium',
  });

  Map<String, dynamic> toJson() {
    return {
      'stateManagement': stateManagement,
      'routing': routing,
      'sessionStrategy': sessionStrategy,
      'environmentStrategy': environmentStrategy,
      'projectScale': projectScale,
    };
  }

  @override
  String toString() {
    return '''
====================================
Technology Compatibility State
====================================
State Management:     $stateManagement
Routing Solution:     $routing
Session Strategy:     $sessionStrategy
Environment Strategy: $environmentStrategy
Project Scale:        $projectScale
====================================''';
  }
}

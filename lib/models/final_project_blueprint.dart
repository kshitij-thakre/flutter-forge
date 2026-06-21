class FinalProjectBlueprint {
  final String stateManagement;
  final String routing;
  final String sessionStrategy;
  final String environmentStrategy;

  const FinalProjectBlueprint({
    required this.stateManagement,
    required this.routing,
    required this.sessionStrategy,
    required this.environmentStrategy,
  });

  Map<String, dynamic> toJson() {
    return {
      'stateManagement': stateManagement,
      'routing': routing,
      'sessionStrategy': sessionStrategy,
      'environmentStrategy': environmentStrategy,
    };
  }

  @override
  String toString() {
    return '''
====================================
Final Project Blueprint
====================================
State Management:     $stateManagement
Routing Solution:     $routing
Session Strategy:     $sessionStrategy
Environment Strategy: $environmentStrategy
====================================''';
  }
}

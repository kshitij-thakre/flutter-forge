class ArchitectureRecommendation {
  final String recommendedStateManagement;
  final String alternativeStateManagement;
  final String recommendedRouting;
  final String sessionStrategy;
  final String environmentStrategy;

  const ArchitectureRecommendation({
    required this.recommendedStateManagement,
    required this.alternativeStateManagement,
    required this.recommendedRouting,
    required this.sessionStrategy,
    required this.environmentStrategy,
  });

  Map<String, dynamic> toJson() {
    return {
      'recommendedStateManagement': recommendedStateManagement,
      'alternativeStateManagement': alternativeStateManagement,
      'recommendedRouting': recommendedRouting,
      'sessionStrategy': sessionStrategy,
      'environmentStrategy': environmentStrategy,
    };
  }

  @override
  String toString() {
    return '''
====================================
Architecture Recommendations
====================================
State Management (Rec): $recommendedStateManagement
State Management (Alt): $alternativeStateManagement
Routing Solution:       $recommendedRouting
Session Strategy:       $sessionStrategy
Environment Strategy:   $environmentStrategy
====================================''';
  }
}

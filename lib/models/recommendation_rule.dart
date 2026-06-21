class RecommendationRule {
  final String category;
  final String trigger;
  final String recommendation;
  final String alternative;
  final String description;

  const RecommendationRule({
    required this.category,
    required this.trigger,
    required this.recommendation,
    required this.alternative,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'trigger': trigger,
      'recommendation': recommendation,
      'alternative': alternative,
      'description': description,
    };
  }

  @override
  String toString() {
    return '''
Category:       $category
Trigger:        $trigger
Recommendation: $recommendation
Alternative:    $alternative
Description:    $description''';
  }
}

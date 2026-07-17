import '../models/recommendation_rule.dart';

class RecommendationRegistryService {
  final List<RecommendationRule> _rules = [
    const RecommendationRule(
      category: 'Project Scale',
      trigger: 'Small',
      recommendation: 'Riverpod, Navigation 2.0',
      alternative: 'Bloc',
      description: 'Recommended setup for small-scale apps.',
    ),
    const RecommendationRule(
      category: 'Project Scale',
      trigger: 'Medium',
      recommendation: 'Riverpod, Go Router',
      alternative: 'Bloc',
      description: 'Recommended setup for medium-scale apps.',
    ),
    const RecommendationRule(
      category: 'Project Scale',
      trigger: 'Enterprise',
      recommendation: 'Riverpod, Go Router',
      alternative: 'Bloc',
      description: 'Recommended setup for enterprise-scale apps.',
    ),
    const RecommendationRule(
      category: 'Authentication',
      trigger: 'Authentication Enabled',
      recommendation: 'Persistent Session Strategy',
      alternative: 'No session storage required',
      description:
          'Recommended session strategy when authentication is enabled.',
    ),
    const RecommendationRule(
      category: 'Environment Setup',
      trigger: 'Environment Setup Enabled',
      recommendation: 'Environment Configuration Strategy',
      alternative: 'Single environment setup',
      description:
          'Recommended environment strategy when multiple environment setups are required.',
    ),
  ];

  List<RecommendationRule> getAllRules() {
    return List.unmodifiable(_rules);
  }

  List<RecommendationRule> getRulesByCategory(String category) {
    return _rules
        .where((r) => r.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  RecommendationRule? getRule(String trigger) {
    for (final rule in _rules) {
      if (rule.trigger.toLowerCase() == trigger.toLowerCase()) {
        return rule;
      }
    }
    return null;
  }

  bool exists(String trigger) {
    return getRule(trigger) != null;
  }
}

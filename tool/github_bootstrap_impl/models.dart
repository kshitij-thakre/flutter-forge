class MilestoneConfig {
  final String title;
  final String description;
  final String?
      dueOn; // Optional due date string (ISO-8601 format: e.g., YYYY-MM-DDTHH:MM:SSZ)

  const MilestoneConfig({
    required this.title,
    required this.description,
    this.dueOn,
  });

  factory MilestoneConfig.fromMap(Map<dynamic, dynamic> map) {
    return MilestoneConfig(
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      dueOn: map['due_on'] as String?,
    );
  }
}

class LabelConfig {
  final String name;
  final String color;
  final String description;

  const LabelConfig({
    required this.name,
    required this.color,
    required this.description,
  });

  factory LabelConfig.fromMap(Map<dynamic, dynamic> map) {
    return LabelConfig(
      name: map['name'] as String? ?? '',
      color: map['color'] as String? ?? '',
      description: map['description'] as String? ?? '',
    );
  }
}

class IssueConfig {
  final String title;
  final String milestone;
  final List<String> labels;
  final String estimate;
  final String priority;
  final String objective;
  final String background;
  final String scope;
  final List<String> deliverables;
  final List<String> acceptanceCriteria;
  final String outOfScope;
  final String dependencies;
  final List<String> testingChecklist;
  final String definitionOfDone;

  const IssueConfig({
    required this.title,
    required this.milestone,
    required this.labels,
    required this.estimate,
    required this.priority,
    required this.objective,
    required this.background,
    required this.scope,
    required this.deliverables,
    required this.acceptanceCriteria,
    required this.outOfScope,
    required this.dependencies,
    required this.testingChecklist,
    required this.definitionOfDone,
  });

  factory IssueConfig.fromMap(Map<dynamic, dynamic> map) {
    return IssueConfig(
      title: map['title'] as String? ?? '',
      milestone: map['milestone'] as String? ?? '',
      labels: (map['labels'] as List<dynamic>?)?.cast<String>() ?? const [],
      estimate: map['estimate'] as String? ?? '',
      priority: map['priority'] as String? ?? '',
      objective: map['objective'] as String? ?? '',
      background: map['background'] as String? ?? '',
      scope: map['scope'] as String? ?? '',
      deliverables:
          (map['deliverables'] as List<dynamic>?)?.cast<String>() ?? const [],
      acceptanceCriteria:
          (map['acceptanceCriteria'] as List<dynamic>?)?.cast<String>() ??
              const [],
      outOfScope: map['outOfScope'] as String? ?? '',
      dependencies: map['dependencies'] as String? ?? '',
      testingChecklist:
          (map['testingChecklist'] as List<dynamic>?)?.cast<String>() ??
              const [],
      definitionOfDone: map['definitionOfDone'] as String? ?? '',
    );
  }
}

class RoadmapConfig {
  final double version;
  final List<MilestoneConfig> milestones;
  final List<LabelConfig> labels;
  final List<IssueConfig> issues;

  const RoadmapConfig({
    required this.version,
    required this.milestones,
    required this.labels,
    required this.issues,
  });
}

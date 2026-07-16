import 'dart:io';
import 'package:yaml/yaml.dart';
import 'models.dart';

class YamlParser {
  RoadmapConfig parse(String yamlPath) {
    final file = File(yamlPath);
    if (!file.existsSync()) {
      throw FileSystemException('Roadmap YAML file not found', yamlPath);
    }
    final content = file.readAsStringSync();
    final doc = loadYaml(content) as YamlMap;

    final version = (doc['version'] as num?)?.toDouble() ?? 3.0;

    final milestonesList = doc['milestones'] as YamlList?;
    final milestones = <MilestoneConfig>[];
    if (milestonesList != null) {
      for (final m in milestonesList) {
        if (m is YamlMap) {
          milestones.add(MilestoneConfig.fromMap(m));
        }
      }
    }

    final labelsList = doc['labels'] as YamlList?;
    final labels = <LabelConfig>[];
    if (labelsList != null) {
      for (final l in labelsList) {
        if (l is YamlMap) {
          labels.add(LabelConfig.fromMap(l));
        }
      }
    }

    final issuesList = doc['issues'] as YamlList?;
    final issues = <IssueConfig>[];
    if (issuesList != null) {
      for (final i in issuesList) {
        if (i is YamlMap) {
          issues.add(IssueConfig.fromMap(i));
        }
      }
    }

    return RoadmapConfig(
      version: version,
      milestones: milestones,
      labels: labels,
      issues: issues,
    );
  }

  String formatIssueBody(IssueConfig issue) {
    final deliverablesMarkdown = issue.deliverables.isEmpty
        ? 'None'
        : issue.deliverables.map((d) => '* $d').join('\n');

    final acMarkdown = issue.acceptanceCriteria.isEmpty
        ? 'None'
        : issue.acceptanceCriteria.map((ac) => '- [ ] $ac').join('\n');

    final testingMarkdown = issue.testingChecklist.isEmpty
        ? 'None'
        : issue.testingChecklist.map((t) => '- [ ] $t').join('\n');

    return '''## Objective
${issue.objective.isEmpty ? 'Not specified' : issue.objective}

## Background
${issue.background.isEmpty ? 'Not specified' : issue.background}

## Scope
${issue.scope.isEmpty ? 'Not specified' : issue.scope}

## Deliverables
$deliverablesMarkdown

## Acceptance Criteria
$acMarkdown

## Out of Scope
${issue.outOfScope.isEmpty ? 'None' : issue.outOfScope}

## Dependencies
${issue.dependencies.isEmpty ? 'None' : issue.dependencies}

## Testing Checklist
$testingMarkdown

## Definition of Done
${issue.definitionOfDone.isEmpty ? 'Code builds cleanly and passes lints.' : issue.definitionOfDone}''';
  }
}

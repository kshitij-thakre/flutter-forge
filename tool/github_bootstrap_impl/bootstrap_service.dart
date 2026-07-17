import 'models.dart';
import 'github_api_client.dart';
import 'logger.dart';
import 'yaml_parser.dart';
import 'validation_service.dart';

class BootstrapService {
  final GitHubApiClient apiClient;
  final Logger logger;
  final YamlParser yamlParser;
  final ValidationService validationService;

  BootstrapService({
    required this.apiClient,
    required this.logger,
    required this.yamlParser,
    required this.validationService,
  });

  bool _isDueDateDifferent(String? yamlDue, String? remoteDue) {
    if (yamlDue == null || yamlDue.isEmpty) {
      return remoteDue != null && remoteDue.isNotEmpty;
    }
    if (remoteDue == null || remoteDue.isEmpty) {
      return true;
    }
    try {
      final yamlDate = DateTime.parse(yamlDue).toUtc();
      final remoteDate = DateTime.parse(remoteDue).toUtc();
      // Compare year, month, day only
      return yamlDate.year != remoteDate.year ||
          yamlDate.month != remoteDate.month ||
          yamlDate.day != remoteDate.day;
    } catch (_) {
      return yamlDue != remoteDue;
    }
  }

  String _normalizeString(String val) {
    return val.replaceAll('\r\n', '\n').replaceAll('\r', '\n').trim();
  }

  bool _isSetEqual(Set<String> a, Set<String> b) {
    return a.length == b.length && a.containsAll(b);
  }

  Future<void> runBootstrap({
    required RoadmapConfig config,
    required String owner,
    required String repo,
    required String token,
    bool isDryRun = false,
  }) async {
    final startTime = DateTime.now();

    logger.info('Running pre-execution validation...');
    final valResult = await validationService.validate(
      config,
      owner: owner,
      repo: repo,
      token: token,
    );

    for (final warning in valResult.warnings) {
      logger.warning(warning);
    }

    if (!valResult.isValid) {
      for (final error in valResult.errors) {
        logger.error(error);
      }
      throw Exception('Validation failed. Aborting bootstrap.');
    }

    logger.success('Validation passed cleanly.');

    logger.info(
        'Fetching existing milestones, labels, and issues from GitHub...');
    List<Map<String, dynamic>> existingMilestones = [];
    List<Map<String, dynamic>> existingLabels = [];
    List<Map<String, dynamic>> existingIssues = [];

    try {
      existingMilestones = await apiClient.getMilestones(owner, repo);
      existingLabels = await apiClient.getLabels(owner, repo);
      existingIssues = await apiClient.getIssues(owner, repo);
    } catch (e) {
      logger.error('Failed to retrieve initial data from GitHub API: $e');
      throw Exception('Fetch error: $e');
    }

    // 1. Calculate Operations
    final milestonesCreate = <MilestoneConfig>[];
    final milestonesUpdate =
        <MapEntry<MilestoneConfig, Map<String, dynamic>>>[];
    final milestonesSkip = <MilestoneConfig>[];

    final labelsCreate = <LabelConfig>[];
    final labelsUpdate = <MapEntry<LabelConfig, Map<String, dynamic>>>[];
    final labelsSkip = <LabelConfig>[];

    final issuesCreate = <IssueConfig>[];
    final issuesUpdate = <MapEntry<IssueConfig, Map<String, dynamic>>>[];
    final issuesSkip = <IssueConfig>[];

    final milestoneMap =
        <String, int>{}; // title to number (existing or created)

    // Analyze Milestones
    for (final configM in config.milestones) {
      final match = existingMilestones.firstWhere(
        (m) =>
            m['title'].toString().toLowerCase() == configM.title.toLowerCase(),
        orElse: () => const {},
      );

      if (match.isEmpty) {
        milestonesCreate.add(configM);
      } else {
        milestoneMap[configM.title] = match['number'] as int;
        final currentDesc = match['description'] as String? ?? '';
        final currentDue = match['due_on'] as String? ?? '';

        bool changes = false;
        final changeReasons = <String>[];
        if (currentDesc != configM.description) {
          changes = true;
          changeReasons.add('description');
        }
        if (_isDueDateDifferent(configM.dueOn, currentDue)) {
          changes = true;
          changeReasons.add('due date');
        }

        if (changes) {
          milestonesUpdate.add(MapEntry(configM, match));
        } else {
          milestonesSkip.add(configM);
        }
      }
    }

    // Analyze Labels
    for (final configL in config.labels) {
      final normalizedConfigColor =
          configL.color.replaceAll('#', '').toLowerCase();
      final match = existingLabels.firstWhere(
        (l) => l['name'].toString().toLowerCase() == configL.name.toLowerCase(),
        orElse: () => const {},
      );

      if (match.isEmpty) {
        labelsCreate.add(configL);
      } else {
        final currentColor = (match['color'] as String? ?? '').toLowerCase();
        final currentDesc = (match['description'] as String? ?? '');

        if (currentColor != normalizedConfigColor ||
            currentDesc != configL.description) {
          labelsUpdate.add(MapEntry(configL, match));
        } else {
          labelsSkip.add(configL);
        }
      }
    }

    // Analyze Issues
    for (final configI in config.issues) {
      final match = existingIssues.firstWhere(
        (i) =>
            i['title'].toString().toLowerCase() == configI.title.toLowerCase(),
        orElse: () => const {},
      );

      if (match.isEmpty) {
        issuesCreate.add(configI);
      } else {
        // Compare Body
        final currentBody = _normalizeString(match['body'] as String? ?? '');
        final expectedBody =
            _normalizeString(yamlParser.formatIssueBody(configI));
        bool bodyDiffers = currentBody != expectedBody;

        // Compare Milestone
        final milestoneObj = match['milestone'] as Map<String, dynamic>?;
        final currentMilestoneTitle = milestoneObj?['title'] as String? ?? '';
        bool milestoneDiffers = currentMilestoneTitle.toLowerCase() !=
            configI.milestone.toLowerCase();

        // Compare Labels
        final currentLabels = (match['labels'] as List<dynamic>?)
                ?.map((l) => l['name'].toString().toLowerCase())
                .toSet() ??
            <String>{};
        final expectedLabels =
            configI.labels.map((l) => l.toLowerCase()).toSet();
        bool labelsDiffer = !_isSetEqual(currentLabels, expectedLabels);

        if (bodyDiffers || milestoneDiffers || labelsDiffer) {
          issuesUpdate.add(MapEntry(configI, match));
        } else {
          issuesSkip.add(configI);
        }
      }
    }

    if (isDryRun) {
      // Print dry-run execution plan
      print('\n================================================');
      logger.bold('Execution Plan - Repository: $owner/$repo');
      print('================================================');
      print('Milestones:');
      print('  Create: ${milestonesCreate.map((m) => m.title).toList()}');
      print('  Update: ${milestonesUpdate.map((m) => m.key.title).toList()}');
      print('  Skip:   ${milestonesSkip.map((m) => m.title).toList()}');
      print('\nLabels:');
      print('  Create: ${labelsCreate.map((l) => l.name).toList()}');
      print('  Update: ${labelsUpdate.map((l) => l.key.name).toList()}');
      print('  Skip:   ${labelsSkip.map((l) => l.name).toList()}');
      print('\nIssues:');
      print('  Create: ${issuesCreate.map((i) => i.title).toList()}');
      print('  Update: ${issuesUpdate.map((i) => i.key.title).toList()}');
      print('  Skip:   ${issuesSkip.map((i) => i.title).toList()}');

      final apiCalls = 5 +
          milestonesCreate.length +
          milestonesUpdate.length +
          labelsCreate.length +
          labelsUpdate.length +
          issuesCreate.length +
          issuesUpdate.length;
      final estimatedMs = apiCalls * 100;

      print('================================================');
      logger.bold('Execution Summary');
      print('================================================');
      print('Estimated API Calls: $apiCalls');
      print('Estimated Time:      $estimatedMs ms');
      print('Warnings:            ${valResult.warnings.length}');
      print('================================================\n');
      return;
    }

    // Active execution
    int milestonesCreatedCount = 0;
    int milestonesUpdatedCount = 0;
    int labelsCreatedCount = 0;
    int labelsUpdatedCount = 0;
    int issuesCreatedCount = 0;
    int issuesUpdatedCount = 0;
    int errorsCount = 0;

    // Apply Milestones
    logger.info('Applying Milestones changes...');
    for (final m in milestonesCreate) {
      try {
        final res = await apiClient.createMilestone(
            owner, repo, m.title, m.description,
            dueOn: m.dueOn);
        milestoneMap[m.title] = res['number'] as int;
        logger.success('Created milestone: "${m.title}"');
        milestonesCreatedCount++;
      } catch (e) {
        logger.error('Failed to create milestone "${m.title}": $e');
        errorsCount++;
      }
    }
    for (final pair in milestonesUpdate) {
      final configM = pair.key;
      final match = pair.value;
      final number = match['number'] as int;
      try {
        await apiClient.updateMilestone(
            owner, repo, number, configM.title, configM.description,
            dueOn: configM.dueOn);
        logger.success('Updated milestone: "${configM.title}"');
        milestonesUpdatedCount++;
      } catch (e) {
        logger.error('Failed to update milestone "${configM.title}": $e');
        errorsCount++;
      }
    }

    // Apply Labels
    logger.info('Applying Labels changes...');
    for (final l in labelsCreate) {
      try {
        await apiClient.createLabel(
            owner, repo, l.name, l.color, l.description);
        logger.success('Created label: "${l.name}"');
        labelsCreatedCount++;
      } catch (e) {
        logger.error('Failed to create label "${l.name}": $e');
        errorsCount++;
      }
    }
    for (final pair in labelsUpdate) {
      final configL = pair.key;
      final match = pair.value;
      try {
        await apiClient.updateLabel(owner, repo, match['name'] as String,
            configL.color, configL.description);
        logger.success('Updated label: "${configL.name}"');
        labelsUpdatedCount++;
      } catch (e) {
        logger.error('Failed to update label "${configL.name}": $e');
        errorsCount++;
      }
    }

    // Apply Issues
    logger.info('Applying Issues changes...');
    for (final i in issuesCreate) {
      final number = milestoneMap[i.milestone];
      final body = yamlParser.formatIssueBody(i);
      try {
        final res = await apiClient.createIssue(
            owner, repo, i.title, body, number, i.labels);
        logger.success('Created issue #${res['number']}: "${i.title}"');
        issuesCreatedCount++;
      } catch (e) {
        logger.error('Failed to create issue "${i.title}": $e');
        errorsCount++;
      }
    }
    for (final pair in issuesUpdate) {
      final configI = pair.key;
      final match = pair.value;
      final issueNumber = match['number'] as int;
      final number = milestoneMap[configI.milestone];
      final body = yamlParser.formatIssueBody(configI);
      try {
        await apiClient.updateIssue(owner, repo, issueNumber, configI.title,
            body, number, configI.labels);
        logger.success('Updated issue #$issueNumber: "${configI.title}"');
        issuesUpdatedCount++;
      } catch (e) {
        logger.error('Failed to update issue "${configI.title}": $e');
        errorsCount++;
      }
    }

    final duration = DateTime.now().difference(startTime);

    // Summary Printing
    print('\n================================================');
    logger.bold('Bootstrap Completed');
    print('================================================');
    print('Milestones:');
    print('  Created: $milestonesCreatedCount');
    print('  Updated: $milestonesUpdatedCount');
    print('  Skipped: ${milestonesSkip.length}');
    print('\nLabels:');
    print('  Created: $labelsCreatedCount');
    print('  Updated: $labelsUpdatedCount');
    print('  Skipped: ${labelsSkip.length}');
    print('\nIssues:');
    print('  Created: $issuesCreatedCount');
    print('  Updated: $issuesUpdatedCount');
    print('  Skipped: ${issuesSkip.length}');
    print('\nRetries:        ${apiClient.retryHandler.retryCount}');
    print('Warnings:       ${valResult.warnings.length}');
    print('Errors:         $errorsCount');
    print('Execution Time: ${duration.inMilliseconds} ms');
    print('================================================\n');

    if (errorsCount > 0) {
      throw Exception('Completed with $errorsCount errors.');
    }
  }

  Future<bool> runVerify({
    required RoadmapConfig config,
    required String owner,
    required String repo,
    required String token,
  }) async {
    logger.info(
        'Executing Verify Alignment between config and remote repository...');

    final valResult = await validationService.validate(
      config,
      owner: owner,
      repo: repo,
      token: token,
    );

    if (!valResult.isValid) {
      for (final error in valResult.errors) {
        logger.error(error);
      }
      return false;
    }

    List<Map<String, dynamic>> existingMilestones = [];
    List<Map<String, dynamic>> existingLabels = [];
    List<Map<String, dynamic>> existingIssues = [];

    try {
      existingMilestones = await apiClient.getMilestones(owner, repo);
      existingLabels = await apiClient.getLabels(owner, repo);
      existingIssues = await apiClient.getIssues(owner, repo);
    } catch (e) {
      logger.error('Fetch failed: $e');
      return false;
    }

    bool isAligned = true;

    print('\n================================================');
    logger.bold('Roadmap Alignment Diagnostics Report');
    print('================================================');

    // Milestones Verify
    print('Milestones:');
    for (final configM in config.milestones) {
      final match = existingMilestones.firstWhere(
        (m) =>
            m['title'].toString().toLowerCase() == configM.title.toLowerCase(),
        orElse: () => const {},
      );

      if (match.isEmpty) {
        logger.error('  [MISSING] Milestone: "${configM.title}"');
        isAligned = false;
      } else {
        final currentDesc = match['description'] as String? ?? '';
        final currentDue = match['due_on'] as String? ?? '';

        if (currentDesc != configM.description ||
            _isDueDateDifferent(configM.dueOn, currentDue)) {
          logger.warning('  [DIFFERENT] Milestone: "${configM.title}"');
          isAligned = false;
        } else {
          logger.success('  [UP-TO-DATE] Milestone: "${configM.title}"');
        }
      }
    }

    // Labels Verify
    print('\nLabels:');
    for (final configL in config.labels) {
      final normalizedConfigColor =
          configL.color.replaceAll('#', '').toLowerCase();
      final match = existingLabels.firstWhere(
        (l) => l['name'].toString().toLowerCase() == configL.name.toLowerCase(),
        orElse: () => const {},
      );

      if (match.isEmpty) {
        logger.error('  [MISSING] Label: "${configL.name}"');
        isAligned = false;
      } else {
        final currentColor = (match['color'] as String? ?? '').toLowerCase();
        final currentDesc = (match['description'] as String? ?? '');

        if (currentColor != normalizedConfigColor ||
            currentDesc != configL.description) {
          logger.warning('  [DIFFERENT] Label: "${configL.name}"');
          isAligned = false;
        } else {
          logger.success('  [UP-TO-DATE] Label: "${configL.name}"');
        }
      }
    }

    // Issues Verify
    print('\nIssues:');
    for (final configI in config.issues) {
      final match = existingIssues.firstWhere(
        (i) =>
            i['title'].toString().toLowerCase() == configI.title.toLowerCase(),
        orElse: () => const {},
      );

      if (match.isEmpty) {
        logger.error('  [MISSING] Issue: "${configI.title}"');
        isAligned = false;
      } else {
        final currentBody = _normalizeString(match['body'] as String? ?? '');
        final expectedBody =
            _normalizeString(yamlParser.formatIssueBody(configI));
        bool bodyDiffers = currentBody != expectedBody;

        final milestoneObj = match['milestone'] as Map<String, dynamic>?;
        final currentMilestoneTitle = milestoneObj?['title'] as String? ?? '';
        bool milestoneDiffers = currentMilestoneTitle.toLowerCase() !=
            configI.milestone.toLowerCase();

        final currentLabels = (match['labels'] as List<dynamic>?)
                ?.map((l) => l['name'].toString().toLowerCase())
                .toSet() ??
            <String>{};
        final expectedLabels =
            configI.labels.map((l) => l.toLowerCase()).toSet();
        bool labelsDiffer = !_isSetEqual(currentLabels, expectedLabels);

        if (bodyDiffers || milestoneDiffers || labelsDiffer) {
          logger.warning('  [DIFFERENT] Issue: "${configI.title}"');
          isAligned = false;
        } else {
          logger.success('  [UP-TO-DATE] Issue: "${configI.title}"');
        }
      }
    }
    print('================================================\n');

    return isAligned;
  }

  Future<void> deleteRelease({
    required RoadmapConfig config,
    required String owner,
    required String repo,
    required String token,
    required String versionTag,
  }) async {
    logger.info('Executing Delete Release for version tag "$versionTag"...');
    final prefix = 'V$versionTag';

    try {
      final existingMilestones = await apiClient.getMilestones(owner, repo);
      final existingIssues = await apiClient.getIssues(owner, repo);

      int closedIssues = 0;
      int deletedMilestones = 0;

      for (final milestone in existingMilestones) {
        final title = milestone['title'] as String;
        if (title.startsWith(prefix)) {
          final milestoneNumber = milestone['number'] as int;

          for (final issue in existingIssues) {
            final milestoneObj = issue['milestone'] as Map<String, dynamic>?;
            if (milestoneObj != null &&
                milestoneObj['number'] == milestoneNumber) {
              final state = issue['state'] as String;
              if (state != 'closed') {
                final issueNumber = issue['number'] as int;
                await apiClient.closeIssue(owner, repo, issueNumber);
                logger
                    .success('Closed issue #$issueNumber: "${issue['title']}"');
                closedIssues++;
              }
            }
          }

          await apiClient.deleteMilestone(owner, repo, milestoneNumber);
          logger.success('Deleted milestone: "$title"');
          deletedMilestones++;
        }
      }

      int deletedLabels = 0;
      for (final label in config.labels) {
        try {
          await apiClient.deleteLabel(owner, repo, label.name);
          logger.success('Deleted label: "${label.name}"');
          deletedLabels++;
        } catch (_) {}
      }

      logger.success('Delete Release complete.');
      logger.bold(
          'Summary: Deleted $deletedMilestones milestones, closed $closedIssues issues, deleted $deletedLabels labels.');
    } catch (e) {
      logger.error('Failed to execute delete release: $e');
      throw Exception('Delete release failed: $e');
    }
  }
}

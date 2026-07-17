import 'models.dart';
import 'github_api_client.dart';

class ValidationResult {
  final List<String> errors;
  final List<String> warnings;

  ValidationResult({required this.errors, required this.warnings});

  bool get isValid => errors.isEmpty;
}

class ValidationService {
  final GitHubApiClient? apiClient;

  ValidationService({this.apiClient});

  Future<ValidationResult> validate(
    RoadmapConfig config, {
    String? owner,
    String? repo,
    String? token,
  }) async {
    final errors = <String>[];
    final warnings = <String>[];

    // 1. Verify GITHUB_TOKEN
    if (token == null || token.isEmpty) {
      errors.add('Environment variable GITHUB_TOKEN is not set or is empty.');
    }

    // 2. Validate Token Permissions & Repository Connection
    if (apiClient != null &&
        owner != null &&
        repo != null &&
        token != null &&
        token.isNotEmpty) {
      try {
        final permInfo = await apiClient!.verifyTokenPermissions();
        final scopes = permInfo['scopes'] as String;
        final scopesList = scopes.split(',').map((s) => s.trim()).toList();

        // If scopes are populated (classic token), check for 'repo'
        if (scopes.isNotEmpty && !scopesList.contains('repo')) {
          errors.add(
              'Insufficient token permissions. GITHUB_TOKEN requires the "repo" scope (Found: $scopes).');
        }
      } catch (e) {
        // If it throws ValidationException with 401, it is invalid token.
        // If it throws a different error, log as error
        errors.add('Token validation failed: $e');
      }

      try {
        final repoExists = await apiClient!.verifyRepository(owner, repo);
        if (!repoExists) {
          errors.add(
              'Repository $owner/$repo does not exist or is not accessible.');
        }
      } catch (e) {
        errors.add('Failed to verify repository connection: $e');
      }
    }

    // 3. Labels configuration validation (check duplicates)
    final labelNames = <String>{};
    for (final label in config.labels) {
      if (label.name.isEmpty) {
        errors.add('Label name cannot be empty.');
      } else {
        final lowerName = label.name.toLowerCase();
        if (labelNames.contains(lowerName)) {
          errors.add(
              'Duplicate label name found in YAML configuration: "${label.name}".');
        }
        labelNames.add(lowerName);
      }
      if (label.color.isEmpty) {
        errors.add('Color for label "${label.name}" cannot be empty.');
      }
    }

    // 4. Milestones configuration validation (check duplicates)
    final milestoneTitles = <String>{};
    for (final milestone in config.milestones) {
      if (milestone.title.isEmpty) {
        errors.add('Milestone title cannot be empty.');
      } else {
        final lowerTitle = milestone.title.toLowerCase();
        if (milestoneTitles.contains(lowerTitle)) {
          errors.add(
              'Duplicate milestone title found in YAML configuration: "${milestone.title}".');
        }
        milestoneTitles.add(lowerTitle);
      }
      if (milestone.description.isEmpty) {
        warnings.add('Milestone "${milestone.title}" has no description.');
      }
    }

    // 5. Issues configuration validation
    final issueTitles = <String>{};
    for (final issue in config.issues) {
      if (issue.title.isEmpty) {
        errors.add('Issue title cannot be empty.');
      } else {
        if (issueTitles.contains(issue.title)) {
          errors.add('Duplicate issue title found in YAML: "${issue.title}".');
        }
        issueTitles.add(issue.title);
      }

      // Verify milestone reference
      if (issue.milestone.isEmpty) {
        errors.add('Issue "${issue.title}" is missing a milestone reference.');
      } else if (!milestoneTitles.contains(issue.milestone.toLowerCase())) {
        errors.add(
            'Issue "${issue.title}" references non-existent milestone: "${issue.milestone}".');
      }

      // Verify labels reference
      for (final labelName in issue.labels) {
        if (!labelNames.contains(labelName.toLowerCase())) {
          errors.add(
              'Issue "${issue.title}" references non-existent label: "$labelName".');
        }
      }

      // Check fields of body template
      if (issue.objective.isEmpty) {
        warnings.add('Issue "${issue.title}" has an empty objective.');
      }
      if (issue.acceptanceCriteria.isEmpty) {
        warnings.add('Issue "${issue.title}" has no acceptance criteria.');
      }
    }

    return ValidationResult(errors: errors, warnings: warnings);
  }
}

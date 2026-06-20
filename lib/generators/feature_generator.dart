import 'dart:io';

/// Responsibility:
/// Scaffolds a new feature module with Presentation, Domain, and Data layers.
/// Generates base screens, repository contracts, implementation scripts, and registers dependency DI.

class FeatureGenerator {
  // TODO: Add methods to construct layered folders (features/feature_name/{data,domain,presentation}).
  // TODO: Add methods to generate template files: screen, repository contract, implementation, state controller.
  // TODO: Add methods to inject the feature dependency bindings into injection.dart.
  // TODO: Add methods to inject route references into app_router.dart.

  Future<void> generateFeature(
    String projectPath,
    String featureName,
  ) async {
    final baseDir = projectPath.endsWith('/')
        ? projectPath.substring(0, projectPath.length - 1)
        : projectPath;

    final directories = [
      'lib/features/$featureName/data/datasources',
      'lib/features/$featureName/data/models',
      'lib/features/$featureName/data/repositories',
      'lib/features/$featureName/domain/entities',
      'lib/features/$featureName/domain/repositories',
      'lib/features/$featureName/domain/usecases',
      'lib/features/$featureName/presentation/screens',
      'lib/features/$featureName/presentation/state',
      'lib/features/$featureName/presentation/widgets',
    ];

    for (final dirPath in directories) {
      final dir = Directory('$baseDir/$dirPath');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    }
  }

  Future<void> generate({
    required String featureName,
    required bool includeData,
    required bool includeRoutes,
  }) async {
    // TODO: Determine base paths using forge.yaml options.
    // TODO: Write folder trees for the feature.
    // TODO: Write template source code files.
    // TODO: Append DI registrations and route tables.
  }
}

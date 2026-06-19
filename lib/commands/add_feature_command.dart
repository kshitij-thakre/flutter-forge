/// Responsibility:
/// Defines and handles execution of the 'forge add feature <feature_name>' command.
/// Validates requirements, reads forge.yaml, and triggers feature scaffolding.

class AddFeatureCommand {
  final String name = 'add';
  final String description = 'Scaffold a new Clean Architecture feature module.';

  // TODO: Add support for flags: --no-data, --no-routes.
  // TODO: Read configuration from forge.yaml.
  // TODO: Inject FeatureGenerator.

  Future<void> run(List<String> arguments) async {
    // TODO: Verify if execution context is inside a valid Forge-initialized project.
    // TODO: Parse feature name and options.
    // TODO: Call FeatureGenerator to scaffold layered folders, create skeleton interfaces, and register DI.
    // TODO: Wire routes automatically if router options are active.
  }
}

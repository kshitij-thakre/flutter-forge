# Changelog

All notable changes to the Flutter Forge project will be documented in this file.

---
## v1.0.1

### Fixed

* Automatic dependency installation during `forge init`.
* Generated Flutter projects now install `dio` automatically.
* Fixed consumer onboarding flow discovered during external acceptance testing.

### Verified

* External repository cloning.
* Project initialization.
* Architecture injection.
* Foundation template generation.
* Feature generation.
* Duplicate protection.
* `flutter analyze`.
* `dart analyze`.


## v1.0.0

### Features
*   **`forge init`**: Scaffold structured Flutter projects.
*   **`forge add feature`**: Scaffolds clean architecture folders inside existing features.

### Completed
*   **Architecture Injector**: Standard directory separations.
*   **Foundation Templates**: Generation of custom exception models and clients.
*   **Feature Generator**: Scaffolding layered Presentation, Domain, and Data modules.
*   **Documentation Suite**: Detailed architecture design docs.
*   **QA Verification**: Comprehensive E2E tests.

---

## v0.4.0-documentation-complete
*   Completed detailed guide books for CLI subcommands, architecture mapping, and release workflows.

---

## v0.3.0-feature-generator
*   Implemented `forge add feature` parser hooks.
*   Automated layering for Presentation, Domain, and Data layers.
*   Prevented duplicate feature name folders.

---

## v0.2.0-foundation-complete
*   Integrated processes checking host Flutter SDK PATH variables.
*   Created default `app_exception.dart`, `exception_mapper.dart`, `api_result.dart`, and `dio_client.dart` templates.

---

## v0.1.0-walking-skeleton
*   Initial project setup.
*   Implemented command parsing shells and argument validation.

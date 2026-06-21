# Changelog

All notable changes to Flutter Forge will be documented in this file.

The format is inspired by Keep a Changelog and follows semantic versioning principles.

---
## v1.0.2 - 2026-06-21

### Improved

- Added global installation instructions
- Added PATH configuration guides for macOS, Linux and Windows
- Added troubleshooting section for `forge: command not found`
- Updated onboarding documentation
- Improved first-time user experience

## v1.0.1 - 2026-06-21


- Added automatic dependency installation during `forge init`.
- Generated Flutter projects now install required packages automatically (`dio`).
- Improved first-time consumer onboarding experience discovered during external acceptance testing.

### Verified

- External repository cloning.
- Project initialization.
- Architecture injection.
- Foundation template generation.
- Feature generation.
- Duplicate project protection.
- Duplicate feature protection.
- `flutter analyze` validation.
- `dart analyze` validation.
- Invalid command handling.

---

## v1.0.0 - 2026-06-20

### Added

#### CLI Commands

- `forge init <project_name>`
- `forge add feature <feature_name>`

#### Core Features

- Golden Flutter project architecture.
- Architecture injector.
- Foundation template generator.
- Feature generator.
- Documentation suite.
- End-to-end QA verification.

---

## v0.4.0-documentation-complete

### Added

- CLI command documentation.
- Architecture documentation.
- Release workflow documentation.
- Developer onboarding guides.

---

## v0.3.0-feature-generator

### Added

- `forge add feature` command parser.
- Automated Clean Architecture feature generation.
- Duplicate feature protection.

### Generated Structure

- Data layer
- Domain layer
- Presentation layer

---

## v0.2.0-foundation-complete

### Added

- Flutter SDK environment validation.
- `app_exception.dart`
- `exception_mapper.dart`
- `api_result.dart`
- `dio_client.dart`

---

## v0.1.0-walking-skeleton

### Added

- Initial Flutter Forge project setup.
- CLI command parsing.
- Argument validation.
- Project repository structure.
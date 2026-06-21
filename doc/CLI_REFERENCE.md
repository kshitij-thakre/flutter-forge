# CLI Reference Manual 🛠️

This document describes the CLI subcommands, input arguments, and verification checks performed by Flutter Forge.

---

## `forge init`

### Purpose
Initializes a new standard Flutter project pre-configured with the Flutter Forge architecture structure.

### Usage
```bash
forge init <project_name>
```

### Validation Rules
*   **Flutter Installed**: Runs environment process validations to verify the Flutter SDK is on the system `PATH`.
*   **Valid Project Name**: Verifies the name corresponds to Dart package naming conventions (only lowercase alphanumeric characters and underscores, matching `^[a-z][a-z0-9_]*$`).
*   **Duplicate Protection**: Verifies that the target project directory does not already exist. If it does, execution is aborted to prevent overwriting code.

---

## `forge add feature`

### Purpose
Scaffolds the Clean Architecture subfolders for a new feature module under the `lib/features/` folder.

### Usage
```bash
forge add feature <feature_name>
```

### Validation Rules
*   **Arguments Structure**: Validates that the execution command contains the `feature` keyword.
*   **Duplicate Protection**: Verifies that the target feature directory (e.g. `lib/features/<feature_name>`) does not already exist on the filesystem. If it exists, execution is stopped immediately.

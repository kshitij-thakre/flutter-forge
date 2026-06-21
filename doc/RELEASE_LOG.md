# Release Log 📋

This document tracks release histories, major version milestones, and structural updates.

---

### v0.1.0-walking-skeleton

*   **Capabilities**:
    *   Basic Dart CLI shell setup.
    *   Command line argument parser logic.
    *   Placeholder entry execution loops.
    *   `forge init` basic command handler setup.

---

### v0.2.0-foundation-complete

*   **Capabilities**:
    *   Process execution wrappers verifying host Flutter SDK installations.
    *   Automated execution of `flutter create` command workflows.
    *   Target folder tree generation.
    *   Injecting standard foundation files (`app_exception.dart`, `exception_mapper.dart`, `api_result.dart`, `dio_client.dart`).
    *   Safety duplicate checks preventing folder overwrites.

---

### v0.3.0-feature-generator

*   **Capabilities**:
    *   Implementing the `forge add feature` execution module.
    *   Scaffolding of isolated Presentation, Domain, and Data subdirectories.
    *   Folder validation checking to ensure features are not duplicated.
    *   Static analysis cleanup, fixing warning/lint issues.

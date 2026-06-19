# V1 Scope: Flutter Forge 🎯

This document outlines the strict boundary of features, platforms, and integrations that define the Version 1.0 (V1) release of Flutter Forge.

---

## ✅ 1. In-Scope for V1

The initial release focuses entirely on establishing high-quality Core Architecture Automation and CLI stability.

### Command Execution & CLI
*   **`forge init <app_name>`**: Automatic generation of architecture scaffolding, dependency declarations, environment setup, and global configurations.
*   **`forge add feature <feature_name>`**: Layered generation of code modules tailored to clean architecture separation.

### Core Architecture Automation
1.  **Folder Structure Generation**:
    *   Creation of clean `lib/core` and `lib/features` directories.
    *   Standard files for app initialization, themes, error wrappers, routers, and dependency locators.
2.  **Dio Network Client Integration**:
    *   Generation of a standardized HTTP client package configuration wrapper.
    *   Pre-wired request/response logger interceptor.
    *   Authentication interceptor token refresh hook (scaffolded method).
3.  **Unified Exception Handling**:
    *   Generation of `AppException` and concrete mapping logic for standard HTTP Status Codes (e.g., 400, 401, 403, 404, 500) and connection timeouts.
4.  **Declarative Route Orchestration**:
    *   Modular router generation using `go_router`.
    *   Automatic generation of feature-level routes that automatically export into the main router.
5.  **Multi-Environment Configuration**:
    *   Three predefined configurations: `dev`, `staging`, and `prod`.
    *   Dart entry files: `main_dev.dart`, `main_staging.dart`, `main_prod.dart`.
    *   Dotenv (`.env`) loading capabilities in Dart runtime.
6.  **Feature Scaffolding**:
    *   Generates layered directories: Data, Domain, and Presentation.
    *   Generates a default screen, mock repository interfaces, and BLoC/Notifier files based on user choice.

---

## ❌ 2. Out-of-Scope for V1

To ensure quality and maintain a tight focus on architecture automation, the following items are strictly out-of-scope for the V1 release:

*   **Third-party Backend Integrations**:
    *   No automatic setup of **Firebase** (auth, firestore, analytics).
    *   No automatic setup of Supabase or AWS Amplify.
*   **Platform & Infrastructure Integration**:
    *   No platform-native configurations (e.g. Android flavors, iOS build schemes) generated via CLI; environment switching is handled purely via Dart/entry points.
    *   No **Docker** files or containerized setup.
    *   No **Azure** services or deployment integrations.
*   **CI/CD Pipeline Generation**:
    *   No GitHub Actions, GitLab CI, or Bitbucket Pipelines generation.
    *   No fastlane setup.
*   **Application Services**:
    *   No **Localization** (intl, custom json translation) scaffolding.
    *   No **Analytics** (Firebase Analytics, Mixpanel) tracking integrations.
*   **AI Integrations**:
    *   No generative AI integrations, LLM hooks, or agentic scaffolds.

---

## 📈 3. Success Metrics for V1

*   **Scaffolding Time**: Reduces Day 0 setup time from 4+ hours of manual copying and dependency patching to under **30 seconds**.
*   **CLI Robustness**: 0% syntax errors in generated code blocks. Generated code must compile cleanly with `flutter analyze` right out of the box.
*   **Zero Architectural Lock-in**: Code created by Flutter Forge must not rely on proprietary/closed library runtimes; developers can uninstall the CLI and continue developing directly with standard Flutter tools.

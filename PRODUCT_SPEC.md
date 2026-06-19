# Product Specification: Flutter Forge 🛠️

This document outlines the detailed product specifications, target audience, key problem statements, and the functional specifications of the CLI tool.

---

## 🎯 1. Target Audience

Flutter Forge is built for:
*   **Solo Developers & Startups**: Teams looking to move rapidly from concept to production without spending critical early days writing core architectural scaffolding.
*   **Tech Leads & Architects**: Individuals who need to establish technical consistency across multi-engineer or multi-team structures.
*   **Mobile Software Agencies**: Agencies that frequently spin up fresh Flutter projects and require a standardized baseline so developers can seamlessly swap projects.

---

## 🔍 2. Problem Statements & Core Solutions

### Problem 1: Folder Structure Inconsistency
*   **The Issue**: Every new developer or team constructs `lib/` differently. Some organize by file type (`models/`, `views/`, `controllers/`), while others organize by feature. This results in significant cognitive load when developers transition between projects or codebases.
*   **Forge Solution**: Enforces a standardized, feature-first folder structure (Presentation, Domain, Data) with a shared `core` folder for cross-cutting concerns.

### Problem 2: Dio Setup Repetition
*   **The Issue**: Configuring a robust HTTP client (Dio) requires repeating boilerplate code for handling base URLs, headers, request/response logging, authentication token refreshes, and SSL pinning.
*   **Forge Solution**: Generates a pre-configured network client with interceptors for authorization headers, structured logging, and token refresh hooks.

### Problem 3: Exception Handling Duplication
*   **The Issue**: Network exceptions, server crashes, connection timeouts, and database failures are caught ad-hoc across the codebase, leading to inconsistent error states in the UI.
*   **Forge Solution**: Standardizes exceptions into a cohesive domain-specific object hierarchy (`AppException`), maps HTTP error codes automatically, and forces clean boundary propagation.

### Problem 4: Route Setup Duplication
*   **The Issue**: As applications grow, route files become bloated, routes are hardcoded, and deep linking becomes complex. Registering a new feature's routes requires editing multiple central files.
*   **Forge Solution**: Implements a modular declarative router setup. When new features are created, Forge automatically wires their routes into the central routing table.

### Problem 5: Environment Setup Duplication
*   **The Issue**: Configuring variables across environments (`dev`, `staging`, `prod`) in Flutter usually involves writing native platform code (flavors in Android/iOS) and setting up complex Dart-side switches.
*   **Forge Solution**: Introduces a zero-platform-friction environment configuration using standard `.env` files and Dart entry points (`main_dev.dart`, `main_staging.dart`, `main_prod.dart`) integrated with build-time options.

### Problem 6: Feature Module Boilerplate
*   **The Issue**: Creating a new feature requires manually building out directories (`features/auth/presentation/widgets/`, `features/auth/domain/repositories/`, etc.), adding files, and registering dependencies in a service locator.
*   **Forge Solution**: A single CLI command scaffolds all directory layers, creates starting templates for repository interfaces, and registers the feature module dependencies automatically.

---

## 🛠️ 3. Functional Specifications (CLI Interface)

### Configuration: `forge.yaml`
When initialized, Flutter Forge places a `forge.yaml` configuration file at the root of the project. This configures the behaviors of feature generation:

```yaml
project_name: my_app
routing: go_router # Choices: go_router, auto_route
state_management: bloc # Choices: bloc, cubit, provider, riverpod, none
network_client: dio
folder_style: feature_first
```

---

### Command: `forge init`
Initializes a new Flutter project or bootstraps an existing blank Flutter project with the Forge architecture.

#### Command Signature:
```bash
forge init <project_name> [options]
```

#### CLI Options:
*   `--path <directory>`: Target directory where the project should be initialized (defaults to current directory).
*   `--state <bloc|riverpod|provider>`: Override state management tool selection (default is `bloc`).
*   `--router <go_router|auto_route>`: Override routing package selection (default is `go_router`).

#### Execution Lifecycle:
1.  Verifies the Flutter SDK environment.
2.  Creates the Flutter project template (if it doesn't exist).
3.  Injects essential dependencies in `pubspec.yaml` (`dio`, `go_router`, `get_it`, `flutter_bloc`, etc.).
4.  Generates the standard folder structure inside `lib/`.
5.  Creates global entry points (`main_dev.dart`, `main_staging.dart`, `main_prod.dart`) and environment configuration files (`.env.dev`, `.env.staging`, `.env.prod`).
6.  Executes `flutter pub get`.

---

### Command: `forge add feature`
Generates a structured, decoupled feature module within the application.

#### Command Signature:
```bash
forge add feature <feature_name> [options]
```

#### CLI Options:
*   `--no-data`: Generates only domain and presentation layers (useful for UI-only modules).
*   `--no-routes`: Skips automatic route registration for this feature.

#### Execution Lifecycle:
1.  Parses `forge.yaml` to identify configured directories and architectural preferences (e.g. `state_management`).
2.  Scaffolds the following folders:
    *   `lib/features/<feature_name>/data/models/`
    *   `lib/features/<feature_name>/data/datasources/`
    *   `lib/features/<feature_name>/data/repositories/`
    *   `lib/features/<feature_name>/domain/entities/`
    *   `lib/features/<feature_name>/domain/usecases/`
    *   `lib/features/<feature_name>/domain/repositories/`
    *   `lib/features/<feature_name>/presentation/screens/`
    *   `lib/features/<feature_name>/presentation/widgets/`
    *   `lib/features/<feature_name>/presentation/controllers/` (or BLoC directory structure)
3.  Creates initial skeleton files:
    *   `<feature_name>_repository.dart` (interface in Domain).
    *   `<feature_name>_repository_impl.dart` (concrete implementation in Data).
    *   `<feature_name>_screen.dart` (UI widget in Presentation).
4.  Registers dependency injection setups (Service Locator bindings) inside the feature module.
5.  If routing is active, creates `<feature_name>_routes.dart` and automatically includes it in the global route mapping.

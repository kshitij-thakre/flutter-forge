# Flutter Forge 🛠️

**Flutter Forge** is an open-source Dart CLI tool designed to solve **Day 0 setup friction** in Flutter applications by automating project structure and boilerplate scaffolding.

---

## What is Flutter Forge?

Flutter Forge is a developer-first tool built to scaffold standardized architectures for new Flutter projects. It never replaces Flutter; it extends it by owning the application folder design and generating minimal, clean architecture skeletons.

---

## Features

*   📂 **Consistent Folder Structure**: Feature-first layout dividing logic into app, core, and features folders.
*   🔌 **Dio Networking Layer**: Pre-configured HTTP client setups with standard exceptions.
*   🛡️ **Standardized Exception Handling**: Converts low-level errors into human-readable domain-specific exceptions.
*   🚦 **Router Scaffolding**: Declarative routing structures prepared for navigation configurations.
*   🌍 **Environment Setup**: Standard entry configurations for developmental configurations.
*   ⚡ **Feature Module Scaffolding**: Generate standard layered feature architectures on demand.

---

## Quick Start

### 1. Initialize a Project
Create a new project pre-configured with the Flutter Forge structure:
```bash
dart run bin/forge.dart init my_app
```

### 2. Scaffold a Feature
Add a new layered feature module to your existing project:
```bash
cd my_app
dart ../bin/forge.dart add feature auth
```

---

## Architecture

Flutter Forge structures generated code inside target projects using the following layer separation:

```text
lib/
├── app/          # Configurations and routing tables
├── core/         # Reusable foundation wrappers (network, exceptions, storage, services, utils)
├── features/     # Feature-level business modules (each with data, domain, and presentation layers)
└── main.dart     # Application entrypoint
```

For a comprehensive explanation of how this works, see [Getting Started](file:///Users/kshitijthakre/Apps/flutter-forge/docs/GETTING_STARTED.md) and [Architecture Guide](file:///Users/kshitijthakre/Apps/flutter-forge/docs/ARCHITECTURE.md).

---

## Roadmap

### Upcoming
*   Documentation improvements
*   QA & Release

### Future Releases
*   Firebase
*   CI/CD
*   Localization
*   Analytics
*   Docker
*   Azure
*   AI Integrations
*   Plugin Marketplace

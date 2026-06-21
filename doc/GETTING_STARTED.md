# Getting Started with Flutter Forge 🚀

This guide will help you set up and run Flutter Forge in less than 5 minutes.

---

## What is Flutter Forge?

**Flutter Forge** is a Dart CLI tool built to eliminate repetitive Day 0 setup tasks in Flutter. Instead of spending hours defining custom exception mapping, scaffolding Clean Architecture layers, configuring environment entry points, or setting up Dio wrappers, Flutter Forge scaffolds a standardized engineering structure in seconds.

---

## Requirements

Ensure the following tools are installed on your host system and available on your system `PATH`:

*   **Dart SDK** (>= 3.0.0)
*   **Flutter SDK** (>= 3.10.0)

---

## Create a Project

To initialize a new Flutter project pre-configured with the standard layout:

```bash
dart run bin/forge.dart init my_app
```

This command runs project validation checkups, executes `flutter create my_app`, injects the core directory structure, and scaffolds foundation code templates.

---

## Create a Feature

To add a new layered feature module to your project:

```bash
cd my_app
dart ../bin/forge.dart add feature auth
```

This command will immediately construct empty Clean Architecture subfolders for the `auth` module under `lib/features/auth/`.

---

## Example Workflow

Here is a complete setup sequence to start a telemedicine app with multiple modules:

```bash
# 1. Initialize project
dart run bin/forge.dart init telemedicine_app

# 2. Navigate to project root
cd telemedicine_app

# 3. Scaffold auth module
dart ../bin/forge.dart add feature auth

# 4. Scaffold dashboard module
dart ../bin/forge.dart add feature dashboard
```

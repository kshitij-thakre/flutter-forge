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

## Installation

Install **Ironship** globally via `pub.dev`:

```bash
dart pub global activate ironship
```

### PATH Configuration

If the `forge` command is not found after activation, add the Dart SDK global bin folder to your system `PATH`:

#### macOS & Linux (zsh/bash)
Run the following to add it for the current session:
```bash
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

To configure it permanently, add it to your shell configuration (e.g., `~/.zshrc` or `~/.bashrc`):
1. Open the configuration file:
   ```bash
   nano ~/.zshrc
   ```
2. Paste the following line at the end:
   ```bash
   export PATH="$PATH":"$HOME/.pub-cache/bin"
   ```
3. Save and reload the shell:
   ```bash
   source ~/.zshrc
   ```

#### Windows
1. Open the **Start Menu** and search for **Environment Variables**.
2. Select **Edit the system environment variables**.
3. Click on the **Environment Variables...** button.
4. Under **User variables**, select `Path` and click **Edit**.
5. Click **New** and add the following folder (replace `<Username>` with your Windows account name):
   ```text
   %USERPROFILE%\AppData\Local\Pub\Cache\bin
   ```
6. Click **OK** to save all dialogs, then restart your terminal.

### Troubleshooting
If you receive the error `forge: command not found` after running the activation script, it indicates your terminal cannot find the executable in the system `PATH`. Make sure the PATH configuration steps above have been applied and your terminal session has been restarted/reloaded.

---

## Quick Start

### 1. Verify Installation
```bash
forge
```

### 2. Initialize a Project
Create a new project pre-configured with the standard architecture:
```bash
forge init demo_app
```

### 3. Scaffold a Feature
Navigate to the project directory, verify code health, and add a Clean Architecture module:
```bash
cd demo_app
flutter analyze
forge add feature auth
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

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
4. Under **User variables**, select `Path` and edit it to append:
   ```text
   %USERPROFILE%\AppData\Local\Pub\Cache\bin
   ```
5. Restart your terminal.

---

## Create a Project

To initialize a new project:

```bash
forge init my_app
```

This command runs project validation checkups, executes `flutter create my_app`, injects the core directory structure, and scaffolds foundation code templates.

---

## Create a Feature

To add a new layered feature module to your project:

```bash
cd my_app
forge add feature auth
```

This command will immediately construct empty Clean Architecture subfolders for the `auth` module under `lib/features/auth/`.

---

## Example Workflow & Verification

Here is a complete setup sequence to verify everything is working end-to-end:

```bash
# 1. Verify CLI is available
forge

# 2. Initialize project
forge init telemedicine_app

# 3. Navigate to project root
cd telemedicine_app

# 4. Verify baseline project health
flutter analyze

# 5. Scaffold auth module
forge add feature auth

# 6. Scaffold dashboard module
forge add feature dashboard
```

---

## Troubleshooting

### Error: `forge: command not found`
This indicates the global binary is not mapped in your system `PATH`. Follow the **PATH Configuration** steps above to add the Pub bin folder to your environment, reload your terminal, and try again.

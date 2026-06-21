# Getting Started with Flutter Forge 🚀

This guide will help you set up and run Flutter Forge in less than 5 minutes.

---

## What is Flutter Forge?

**Flutter Forge** is a Dart CLI tool built to eliminate repetitive Day 0 setup tasks in Flutter. Instead of spending hours defining custom exception mapping, scaffolding Clean Architecture layers, configuring environment entry points, or setting up Dio wrappers, Flutter Forge scaffolds a standardized engineering structure in seconds.

---

## Requirements

Ensure the following tools are installed on your host system and available on your system `PATH`:
- **Dart SDK** (>= 3.0.0)
- **Flutter SDK** (>= 3.10.0)

---

## Installation

Global installation.

```bash
dart pub global activate ironship
```

---

## PATH Setup

Ensure the global packages bin directory is in your system `PATH` to execute the `forge` command directly:

### macOS (zsh)

```bash
echo 'export PATH="$PATH:$HOME/.pub-cache/bin"' >> ~/.zshrc

source ~/.zshrc
```

### Linux

```bash
echo 'export PATH="$PATH:$HOME/.pub-cache/bin"' >> ~/.bashrc

source ~/.bashrc
```

### Windows

To configure the PATH environment variable on Windows:
1. Open the **Start Menu** and search for **Environment Variables**.
2. Select **Edit the system environment variables**.
3. Click the **Environment Variables...** button.
4. Under **User variables**, select `Path` and click **Edit**.
5. Click **New** and add the following directory path:
   ```text
   %USERPROFILE%\AppData\Local\Pub\Cache\bin
   ```
6. Click **OK** on all windows to save the changes, then restart your terminal.

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

## Verification

Provide E2E verification flow.

```bash
forge

forge init demo_app

cd demo_app

flutter analyze

forge add feature auth
```

Expected result:

No issues found.

---

## Troubleshooting

### Error: `forge: command not found`
This indicates the global binary is not mapped in your system `PATH`. Follow the **PATH Setup** steps above to add the Pub bin folder to your environment, reload your terminal, and try again.

# Ironship CLI Example ⚓

This example demonstrates how to use the Ironship CLI to bootstrap a Flutter project with a Clean Architecture layout.

---

## 1. Global Installation

First, activate the `ironship` CLI tool globally using the Dart SDK:

```bash
dart pub global activate ironship
```

*Note: Ensure your system environment variables have the pub-cache bin path configured. See the main README PATH Setup.*

---

## 2. Command Line Help

To inspect all available commands and flags:

```bash
forge --help
```

---

## 3. Project Scaffolding Flow

Initialize a new project (e.g., `hospital_app`) using the `init` command:

```bash
forge init hospital_app
```

This triggers the interactive workflow step-by-step:

### Step A: Discovery Engine (Interactive Questionnaire)
The Discovery Engine gathers requirements through interactive terminal questions:

```text
==================================================
          Ironship Project Discovery Engine
==================================================

Which state management would you like to use?
  [1] Riverpod
  [2] Bloc
  [3] Provider
  [4] Recommend for me
Select option (1-4): 1

Which routing solution would you like to use?
  [1] Navigation 2.0
  [2] Go Router
  [3] Auto Route
  [4] Recommend for me
Select option (1-4): 2

What type of application are you building?
  [1] Simple App
  [2] Medium Scale App
  [3] Enterprise App
Select option (1-3): 3

Approximately how many screens will your application have?
  [1] 1-10
  [2] 10-30
  [3] 30-100
  [4] 100+
Select option (1-4): 3

Will authentication be required?
  [1] Yes
  [2] No
Select option (1-2) or enter (y/n): y

Will session persistence be required?
  [1] Yes
  [2] No
Select option (1-2) or enter (y/n): y

Which environments do you need?
  [1] Dev only
  [2] Dev + Stage
  [3] Dev + Stage + Production
Select option (1-3): 3
```

---

### Step B: Recommendation Engine
Based on requirements, Ironship recommends a custom-tailored configuration:

```text
==================================================
          Recommended Architecture Configuration
==================================================
State Management:     Riverpod
Routing Solution:     Go Router
Session Strategy:     Persistent Session
Environment Strategy: Dev + Stage + Production
==================================================

Do you want to override these selections? (y/N): N
```

---

### Step C: Project Blueprint Validation
Ironship validates cross-package compatibility and compiles a concrete blueprint:

```text
Generating Final Project Blueprint...
====================================
Final Project Blueprint
====================================
State Management:     Riverpod
Routing Solution:     Go Router
Session Strategy:     Persistent Session
Environment Strategy: Dev + Stage + Production
====================================
```

---

### Step D: Architecture Generation & Initialization
Ironship creates the standard Flutter repository structure, injects Clean Architecture core layers, scaffolds specific code modules (Dio HTTP clients, AppException adapters, environment managers, state files, routers), and resolves external dependencies automatically:

```text
Creating Flutter project...
Flutter project created.
Saving configuration...
Configuration saved.
Generating Architecture Layers...
Architecture layers generated.
Generating architecture modules...
Aggregating dependencies...
Installing dependencies: dio, flutter_riverpod, go_router, flutter_secure_storage...
Dependencies installed.

Project initialization complete!
```

---

## 4. Scaffolded Clean Architecture Layout

After initialization, your project structure looks like this:

```text
hospital_app/
├── forge_config.json        # Persisted questionnaire requirements
└── lib/
    ├── main.dart            # Flutter entry point
    ├── app/                 # App configurations and global routing rules
    │   ├── config/
    │   └── routes/
    ├── core/                # Reusable shared infrastructure
    │   ├── exceptions/      # AppException definitions and mapping adapters
    │   │   ├── app_exception.dart
    │   │   └── exception_mapper.dart
    │   ├── network/         # ApiResult container and Dio HTTP client
    │   │   ├── api_result.dart
    │   │   └── dio_client.dart
    │   ├── services/
    │   ├── storage/
    │   └── utils/
    └── features/            # Business feature modules (empty by default)
```

---

## 5. Scaffolding Feature Modules

Once initialized, new Clean Architecture features can be generated on-demand:

```bash
cd hospital_app
forge add feature appointments
```

This generates `lib/features/appointments/` complete with its layered folders:
```text
appointments/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── screens/
    ├── state/
    └── widgets/
```

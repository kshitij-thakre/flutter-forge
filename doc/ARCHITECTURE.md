# Architecture & Design: Flutter Forge 🏛️

This document outlines the architectural blueprints, separation constraints, and folder conventions enforced by Flutter Forge.

---

## Golden Project Template

The directory layout created by the CLI inside a project is organized as follows:

```text
lib/
├── main.dart
│
├── app/
│   ├── config/
│   └── routes/
│
├── core/
│   ├── exceptions/
│   │   ├── app_exception.dart
│   │   └── exception_mapper.dart
│   ├── network/
│   │   ├── api_result.dart
│   │   └── dio_client.dart
│   ├── services/
│   ├── storage/
│   └── utils/
│
└── features/
```

### Layer Responsibilities

### `lib/app/`
*   **Purpose**: The configuration layer of the application.
*   **Description**: Holds global settings, custom route paths setups, and system-wide router configurations.

### `lib/core/`
*   **Purpose**: The shared, reusable engineering foundation.
*   **Description**: Contains platform-agnostic code templates including HTTP client drivers (`DioClient`), response status wrappers (`ApiResult`), mapping helper functions, and custom exception objects.

### `lib/features/`
*   **Purpose**: Contain isolated business feature modules.
*   **Description**: Every feature created (e.g. `auth`) is structured inside its own directory. Features have zero dependencies on other features.

Inside each feature (e.g. `lib/features/auth/`), code is separated into Clean Architecture layers:
```text
lib/features/auth/
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

---

## Ownership Rules

We enforce a strict boundary between what the CLI builds and what the developer owns:

| Component | Action | Description |
| :--- | :--- | :--- |
| **Folders** | Inject Every Time | Flutter Forge verifies the path structures and creates folders recursively if missing. |
| **Foundation Templates** | Scaffold Once | Base client files (`app_exception.dart`, `dio_client.dart`, etc.) are generated once. The CLI skips creation if they already exist. |
| **Business Logic** | Developer Owned Forever | Domain models, repositories, and state controllers belong to the developer. |
| **Flutter Forge CLI** | Never Overwrites | The tool never overrides, rewrites, or deletes code files created or modified by developers. |

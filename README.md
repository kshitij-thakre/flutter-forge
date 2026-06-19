# Flutter Forge 🛠️

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Pub Version](https://img.shields.io/pub/v/flutter_forge.svg)](https://pub.dev/packages/flutter_forge)
[![Dart SDK](https://img.shields.io/badge/dart-%3E%3D3.0.0-blue.svg)](https://dart.dev)
[![Flutter](https://img.shields.io/badge/flutter-%3E%3D3.10.0-blue.svg)](https://flutter.dev)

**Flutter Forge** is a developer-first Dart CLI tool designed to solve **Day 0 setup friction** in Flutter applications. Instead of wasting hours configuring directory trees, copying boilerplate networking files, wiring up route definitions, or setting up environments, Flutter Forge does it for you in seconds—generating a clean, production-ready architecture.

---

## 📖 Core Philosophy

> **"Flutter Forge extends Flutter; it never replaces it."**

Flutter Forge is built on strict boundaries of responsibility:
*   **Forge owns the application architecture** (directory layout, HTTP client abstractions, standardized exception handling, dependency injection configurations, environment separation).
*   **Flutter owns the platform code** (native runners, platform channels, rendering engine, and core SDK integrations).

By generating standard, boilerplate-free Dart code and configuration files, Flutter Forge leaves **zero tool lock-in**. If you decide to stop using Forge, your app remains 100% standard Flutter.

---

## 🚀 Key Features

*   📂 **Consistent Folder Structure**: Generates a standardized, feature-first structure that scales seamlessly from small projects to enterprise monorepos.
*   🔌 **Dio Networking Layer**: A pre-configured, resilient HTTP client featuring robust interceptors, SSL pinning placeholders, and automatic token refreshing.
*   🛡️ **Standardized Exception Handling**: Converts low-level HTTP/Dio errors into human-readable, domain-specific domain exceptions right out of the box.
*   🚦 **Declarative Route Orchestration**: A clean, scalable route configuration system leveraging `go_router` or standard router patterns, modularized by feature.
*   🌍 **Flavor-Ready Environments**: Multi-flavor environment configuration (`dev`, `staging`, `prod`) using `.env` files and entry points without platform-level friction.
*   ⚡ **Feature Module Generation**: Scaffolds new feature modules with structured presentation, domain, and data layers instantly.

---

## 🛠️ V1 Commands

Using Flutter Forge is extremely straightforward:

### 1. Initialize a Project
Create a new Flutter project pre-configured with the Flutter Forge architecture:
```bash
forge init my_app
```

### 2. Generate a Feature Module
Scaffold a complete, layered feature module (e.g., authentication) and register its routes automatically:
```bash
forge add feature auth
```

---

## 📂 Documentation Index

To understand the full architecture, scope, and direction of Flutter Forge, explore our technical documentation:

1.  **[Product Specification](file:///Users/kshitijthakre/Apps/flutter-forge/PRODUCT_SPEC.md)**: Product details, CLI command syntax, and targeted user problems.
2.  **[V1 Scope](file:///Users/kshitijthakre/Apps/flutter-forge/V1_SCOPE.md)**: Explicit list of what is included, what is excluded, and success metrics for our initial release.
3.  **[Architecture Principles](file:///Users/kshitijthakre/Apps/flutter-forge/ARCHITECTURE_PRINCIPLES.md)**: In-depth breakdown of Clean Architecture layers, networking patterns, error mapping, and state boundaries.
4.  **[Folder Structure](file:///Users/kshitijthakre/Apps/flutter-forge/FOLDER_STRUCTURE.md)**: Detailed directory tree mapping and file-by-file explanations.
5.  **[Project Roadmap](file:///Users/kshitijthakre/Apps/flutter-forge/ROADMAP.md)**: Visualizing the phases from V1 foundation to enterprise scaling.

---

## 🤝 Contributing

We welcome contributions from the open-source community! Please see our [Roadmap](file:///Users/kshitijthakre/Apps/flutter-forge/ROADMAP.md) to understand current priorities. If you encounter any bugs, feel free to open an issue or submit a pull request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](file:///Users/kshitijthakre/Apps/flutter-forge/LICENSE) file for details.

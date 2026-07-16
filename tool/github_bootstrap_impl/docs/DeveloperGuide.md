# Developer Guide: Modifying and Testing the Bootstrap Tool

This guide explains how to extend, debug, and run tests for the GitHub Roadmap Bootstrap tool.

---

## Directory Structure

All source files are located in `tool/github_bootstrap_impl/` and imported relatively into `tool/github_bootstrap.dart`:
```text
tool/
├── github_bootstrap.dart       # CLI Main execution entrypoint
└── github_bootstrap_impl/      # Implementations folder
    ├── models.dart             # Configuration models
    ├── yaml_parser.dart        # YAML loader and template formattings
    ├── retry_handler.dart      # Resilience, backoff, and rates handling
    ├── github_api_client.dart  # REST endpoints interfacing
    ├── validation_service.dart # Sanity check validations
    ├── bootstrap_service.dart  # Main synchronization orchestration
    └── logger.dart             # CLI Output logs utilities
```

---

## Running Unit Tests

Unit tests are written using `package:test` and do not require internet access or access tokens. They leverage mock HTTP clients to verify client states and rates delays.

To execute tests:
```bash
dart test test/github_bootstrap_test.dart
```

### Writing New Tests
When adding new API functions, make sure to add mock endpoint responses in `test/github_bootstrap_test.dart` within the `GitHub API Client & Mock Sync Tests` group.

---

## Troubleshooting & Debugging

### 1. Verification Diagnostics
If you are unsure why a validation fails, execute the `validate` command:
```bash
dart run tool/github_bootstrap validate
```

### 2. Mocking rates limit behaviors locally
You can mock GitHub's rates behavior in unit tests by specifying a mock headers map containing:
- `retry-after`: time in seconds before retry is allowed.
- `x-ratelimit-remaining`: `0` to signal rate limit blockages.
- `x-ratelimit-reset`: Unix epoch reset timestamp.

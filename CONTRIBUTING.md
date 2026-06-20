# Contributing to Flutter Forge 🤝

Thank you for your interest in improving Flutter Forge! This document outlines guidelines and development practices for open-source contributions.

---

## How to Contribute
1.  Search our issue tracker to ensure your suggestion or bug report is not duplicate.
2.  If it doesn't exist, open a new issue describing the problem or proposal clearly.
3.  Fork the repository and implement your changes following the development flow below.

---

## Development Flow
1.  Create a feature branch from the main branch.
2.  Ensure code compiles correctly with standard Dart analysis rules.
3.  Write automated tests inside the `test/` directory to cover your additions.
4.  Run validation checks locally before submitting code changes.

---

## Engineering Rules
*   **One Checkbox at a Time**: Work sequentially. Complete one task or checkbox item before moving to the next.
*   **One Prompt at a Time**: When using automated systems or AI assistance, implement changes incrementally step-by-step.
*   **Every Task Ends with Verification**: Always verify that code builds, formats, and passes tests upon task completion.
*   **Never Overwrite Developer-Owned Code**: Respect Scaffold Once boundaries. Skeletons should only be generated if files do not exist.
*   **Never Implement Future Roadmap Items**: Keep changes tightly aligned with the current milestone's scope. Do not overengineer.

---

## Pull Request Process
1.  Ensure all linter checks pass cleanly by running `dart analyze`.
2.  Submit a Pull Request targeting the `main` branch.
3.  Provide a clear description of the problem solved, files changed, and test commands used.
4.  Await maintainer review and address any feedback before merging.

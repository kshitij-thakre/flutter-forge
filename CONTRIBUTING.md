# Contributing to Flutter Forge 🤝

Thank you for your interest in improving Flutter Forge! This document outlines guidelines and development practices for open-source contributions.

---

## How to Contribute
1.  Search our issue tracker to ensure your suggestion or bug report is not duplicate.
2.  If it doesn't exist, open a new issue describing the problem or proposal clearly.
3.  Fork the repository and implement your changes following the development flow below.

---

## Git Workflow Lifecycle

Ironship enforces a structured Git workflow to maintain repository traceability and enable automated issue closing. Every issue must progress through the following lifecycle:

```
GitHub Issue
     ↓
Create Feature Branch
     ↓
Implement Changes
     ↓
Run Unit Tests
     ↓
Manual Verification
     ↓
Conventional Commit
     ↓
Push Feature Branch
     ↓
Open Pull Request (Linked to Issue)
     ↓
Merge Pull Request
     ↓
Issue Closes Automatically
```

### 1. Branch Naming Convention

Feature branches must target the standard naming format:
`feature/<issue-number>-<short-description-slug>`

Examples:
* `feature/32-cli-foundation`
* `feature/33-ironship-config`
* `feature/34-smart-feature-generator`

### 2. Commit Message Convention

Commits must follow the **Conventional Commits** specification and reference their target issue numbers.

Format:
`<type>(<scope>): <description> (#<issue-number>)`

Common Types:
* `feat`: A new user-facing feature.
* `fix`: A bug fix.
* `docs`: Documentation changes.
* `test`: Adding or correcting tests.
* `refactor`: Code changes that neither fix a bug nor add a feature.

Examples:
* `feat(cli): implement CLI foundation (#32)`
* `feat(config): implement ironship.yaml engine (#33)`
* `test(generator): expand feature builder unit tests (#34)`

### 3. Pull Request & Issue Closing

* Always instantiate pull requests using the project's [Pull Request Template](.github/pull_request_template.md).
* Link the pull request to the target issue by including the closing keyword at the bottom of the PR description:
  ```markdown
  Closes #<issue-number>
  ```
* Once reviewed and approved, merge PRs using the **Squash and Merge** strategy. This groups all commits from the branch into a single structured Conventional Commit on the `main` branch. GitHub will automatically close the linked issue upon merging.

### 4. Issue #32 Recovery Guidelines

Since Issue #32 was implemented directly on `main`, contributors should follow this recovery process to maintain project traceability without altering historical commit hashes:
1. Push any remaining local changes:
   ```bash
   git push origin main
   ```
2. Reference the target merge commit hash directly in the comments of Issue #32.
3. Close Issue #32 manually via the GitHub issues UI.
4. Begin working on Issue #33 using the standard feature branch lifecycle.

### 5. Developer Workflow Automation

To simplify Git and PR actions, use the `dev_workflow` developer CLI utility:

* **Create and checkout feature branches**:
  ```bash
  dart run tool/dev_workflow branch 33 "ironship-config"
  ```
* **Stage and commit conventional updates**:
  ```bash
  dart run tool/dev_workflow commit \
      --type feat \
      --scope config \
      --issue 33 \
      --message "implement ironship configuration engine"
  ```
* **Push features branch upstream**:
  ```bash
  dart run tool/dev_workflow push
  ```
* **Open linked pull requests**:
  ```bash
  dart run tool/dev_workflow pr \
      --issue 33 \
      --title "Implement ironship configuration engine"
  ```

If the GitHub CLI (`gh`) is locally installed, `dev_workflow pr` submits the PR automatically. Otherwise, it prints the formatted PR title and Markdown body for manual submission.

---

## Engineering Rules
*   **One Checkbox at a Time**: Work sequentially. Complete one task or checkbox item before moving to the next.
*   **One Prompt at a Time**: When using automated systems or AI assistance, implement changes incrementally step-by-step.
*   **Every Task Ends with Verification**: Always verify that code builds, formats, and passes tests upon task completion.
*   **Never Overwrite Developer-Owned Code**: Respect Scaffold Once boundaries. Skeletons should only be generated if files do not exist.
*   **Never Implement Future Roadmap Items**: Keep changes tightly aligned with the current milestone's scope. Do not overengineer.


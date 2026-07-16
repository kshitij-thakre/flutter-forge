# GitHub Roadmap Bootstrap Tool ⚓

The GitHub Roadmap Bootstrap tool is a utility designed for Ironship maintainers to automate the creation of milestones, labels, issues, and template-based issue descriptions directly from a YAML configuration file.

This tool communicates directly with the GitHub REST API, bypassing standard process dependencies like the GitHub CLI (`gh`).

---

## Features

- **Declarative Releases**: Define all milestones, labels, and issues in a single configuration file (`roadmaps/v3.yaml`).
- **Synchronized State**: Creates resources if they are missing or updates existing resources (e.g. updating description or colors).
- **Issue Body Templating**: Standardizes issue creation using a comprehensive Markdown schema.
- **Prevent Duplicate Issues**: Verifies issue existence (both open and closed) before execution to prevent duplication.
- **Retry & Rate Limit Handling**: Automatic recovery and retries with exponential backoff on transient HTTP 5xx errors or GitHub API rate limits.
- **Dry Run Support**: Perform full validations and prints planned operations without writing data to GitHub.
- **Delete Release Cleanups**: Easily reset milestones, issues, and labels using target version tags.

---

## Setup & Configuration

### Prerequisites
1. **GitHub Access Token**:
   Generate a personal access token (classic or fine-grained) with `repo` scopes. Set it as an environment variable:
   ```bash
   export GITHUB_TOKEN="your_personal_access_token_here"
   ```

2. **Roadmap Config File**:
   Create a YAML configuration file representing the release. By default, the tool reads `roadmaps/v3.yaml`.

---

## Usage

Run the tool using the standard Dart runtime:

### 1. Validate Setup
Checks environment variables, offline schemas, YAML structures, duplicate definitions, and prints warnings or errors.
```bash
dart run tool/github_bootstrap validate
```

### 2. Verify Alignment
Compares current repository state (milestones, labels, issues) with config and reports alignment diagnostics without making mutations.
```bash
dart run tool/github_bootstrap verify
```

### 3. Dry Run Verification
Simulates the execution flow, fetches repository data, compares states, and lists what would be created or modified.
```bash
dart run tool/github_bootstrap dry-run
```

### 4. Bootstrap Active Repository
Executes the bootstrap script, modifying milestones, labels, and creating issues.
```bash
dart run tool/github_bootstrap bootstrap
```

### 5. Delete Release Cleanups
Closes issues, deletes milestones, and removes labels associated with a target release version tag (e.g. `3.0`).
```bash
dart run tool/github_bootstrap delete-release 3.0
```

---

## Additional Options

The CLI parser supports additional flags to override defaults:
* `-c, --config`: Path to custom configuration YAML (defaults to `roadmaps/v3.yaml`).
* `-o, --owner`: GitHub repository owner (defaults to `kshitij-thakre`).
* `-r, --repo`: GitHub repository name (defaults to `flutter-forge`).
* `-h, --help`: Displays usage guide.

Example:
```bash
dart run tool/github_bootstrap bootstrap --owner myorg --repo myrepo --config roadmaps/v4.yaml
```

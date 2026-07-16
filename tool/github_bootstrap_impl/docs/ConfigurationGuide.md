# Configuration Guide: Roadmap YAML Specification

The Roadmap Bootstrap tool uses a structured YAML syntax to describe the desired state of milestones, labels, and issues. The default configuration file is `roadmaps/v3.yaml`.

---

## Configuration Schema

### 1. Release Version
A single root-level double property defining the version:
```yaml
version: 3.0
```

### 2. Milestones
A list of milestones to synchronize. Each entry requires a `title` and a `description`, and supports an optional `due_on` ISO date string.
```yaml
milestones:
  - title: V3.0 Core Platform
    description: Core CLI and configuration engine
    due_on: "2026-06-30T00:00:00Z"
```
- **Updates**: If a milestone with the same title already exists, the description or due date is updated if it differs from the YAML configuration.

### 3. Labels
A list of labels to enforce. Colors must be hex codes (with or without `#`).
```yaml
labels:
  - name: enhancement
    color: a2eeef
    description: New feature or request
```
- **Updates**: If a label with the same name already exists, the color and description will be updated if they differ.

### 4. Issues
A list of issues defining release goals. Each issue is structured to map directly to the standardized issue template:

```yaml
issues:
  - title: CLI Foundation
    milestone: V3.0 Core Platform
    labels:
      - cli
      - enhancement
    estimate: Large
    priority: High
    objective: Replace positional parsing with package:args.
    background: The current parser is fragile and relies on direct index matching.
    scope: Implement option parsing, help commands, and robust exit codes.
    deliverables:
      - Integrate package:args
      - Add help command
    acceptanceCriteria:
      - package:args integrated
      - help command works
    outOfScope: Changing generator logic or editing project structures.
    dependencies: None
    testingChecklist:
      - Unit test arguments parser
    definitionOfDone: Code builds cleanly and passes lints.
```

---

## Mapping Fields to Github Descriptions
When creating an issue, the tool formats these parameters into a structured Markdown description:

- **Deliverables**: Formatted as bulleted lists.
- **Acceptance Criteria**: Formatted as checkbox entries (`- [ ]`).
- **Testing Checklist**: Formatted as checkbox entries (`- [ ]`).
- **Standard Layout Headers**: Generated for Objective, Background, Scope, Deliverables, Acceptance Criteria, Out of Scope, Dependencies, Testing Checklist, and Definition of Done.

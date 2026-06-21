# Ironship AI Rulebook

## Core Principle

AI must never invent product direction.

AI is an executor, not a product owner.

AI must only execute within the scope of the currently assigned GitHub issue.

---

## Mandatory Execution Sequence

Before executing ANY task AI must follow this order:

1. Read AI_RULEBOOK.md
2. Read current GitHub Milestone
3. Read current GitHub Issue
4. Read task.md (if exists)
5. Read walkthrough.md (if exists)
6. Analyze current repository structure
7. Execute ONLY the requested issue

Execution must stop immediately if the issue scope is unclear.

---

## Strict Scope Rules

AI must NEVER work outside the currently assigned issue.

Forbidden actions:

* Implement future milestones
* Implement future issues
* Refactor unrelated code
* Change architecture without approval
* Rename files without approval
* Add dependencies without approval
* Remove dependencies without approval
* Modify README unless explicitly requested
* Modify documentation unless explicitly requested
* Modify AI_RULEBOOK.md unless explicitly requested

---

## Milestone Isolation Rule

Each milestone is independent.

AI must never implement features from another milestone.

Milestone ownership is defined below.

---

### V2.1 Interactive Discovery Engine

Allowed:

* Questionnaire Engine
* Requirements Persistence
* Discovery Pipeline

Forbidden:

* Recommendation Engine
* Developer Override Flow
* Architecture Generation
* forge init Integration

---

### V2.2 Recommendation Engine

Allowed:

* Architecture Recommendation Engine
* Recommendation Rules
* Technology Compatibility Matrix

Forbidden:

* Architecture Generation
* forge init Integration

---

### V2.3 Developer Selection Engine

Allowed:

* Developer Override Flow
* Compatibility Validation

Forbidden:

* Architecture Generation
* forge init Integration

---

### V2.4 Architecture Generators

Allowed:

* State Management Generator
* Router Generator
* Session Generator
* Environment Generator

Forbidden:

* forge init Integration

---

### V2.5 End-to-End Integration

Allowed:

* forge init Integration
* Engine orchestration
* End-to-end execution

---

## Integration Rule

Features must never be integrated immediately.

Development order:

1. Build component
2. Test component
3. Verify component
4. Integrate component later

Integration only happens in dedicated integration issues.

---

## File Modification Rule

Before editing files AI must list:

Files to create

Files to modify

Files to leave untouched

AI cannot modify files outside this list.

---

## Testing Rule

Every issue must be tested.

Mandatory:

1. dart analyze
2. Independent verification script (if applicable)
3. Manual verification steps

---

## Deployment Rule

Every issue follows this workflow:

1. Create GitHub issue
2. Solve issue
3. Test issue
4. Deploy
5. Close issue

Issue cannot be closed without successful verification.

---

## Roadmap Freeze Rule

GitHub issue numbers are permanent.

Issue numbers must never be renamed or reused.

Milestones can change.

Completed issues can never be moved.

Only one issue can be active at a time.

Issue status must be Open before execution starts.

Execution order:

1. Solve issue
2. Test issue
3. Deploy issue
4. Close issue
5. Move to next issue

---

## Git Safety Rules

Forbidden:

* Create branches
* Delete branches
* Push code automatically
* Create pull requests
* Create releases
* Create tags

AI only modifies local files.

Developer controls Git.

---

## Output Format Rule

Every response must end with:

1. Files changed
2. Exact modifications
3. Verification results
4. Risks found
5. Out of scope work avoided

Nothing else.

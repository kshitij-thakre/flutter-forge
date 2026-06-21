# Flutter Forge Working Backlog

# Current Status

## Completed GitHub Issues

* [x] #1 Product Specification

* [x] #2 Define Architecture

* [x] #3 Setup Dart CLI Project

* [x] #4 Build forge init command

* [x] #5 Build Architecture Injector

---

# Completed Features

## forge init

### Capabilities

* [x] Flutter SDK validation

* [x] Project name validation

* [x] Duplicate project protection

* [x] Flutter project creation

* [x] Architecture folder injection

* [x] Foundation templates generation

---

## Golden Project Template v1

```text
lib/

app/
├── config/
└── routes/

core/
├── network/
│   ├── dio_client.dart
│   └── api_result.dart
│
├── exceptions/
│   ├── app_exception.dart
│   └── exception_mapper.dart
│
├── storage/
├── services/
└── utils/

features/

main.dart
```

---

# Ownership Rules

## Folders

* Inject every time

## Foundation Files

* Scaffold once

## Business Logic

* Developer owned forever

## Flutter Forge

* Never overwrites developer code

---

# Verification Completed

* [x] Architecture injection

* [x] Foundation template generation

* [x] Duplicate project protection

* [x] Analyzer warnings fixed

* [x] Golden path verified

* [x] dart analyze passes

---

# Current Focus

## #6 Build Feature Generator

### Goal

Command:

```bash
forge add feature auth
```

Expected output:

```text
features/

auth/

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
    ├── widgets/
    └── controllers/
```

---

# Upcoming Tasks

## Design Contract

* [ ] Finalize feature module structure

* [ ] Define ownership rules

## Implementation

* [ ] Build feature folder generator

* [ ] Connect generator with forge add feature

## Verification

* [ ] Verify feature generation

* [ ] Verify duplicate feature protection

* [ ] Verify dart analyze

---

# Upcoming GitHub Issues

* [ ] #7 Documentation

* [ ] #8 Testing & Release

---

# Definition Of Done

A task is complete only if:

* [ ] Feature implemented

* [ ] Manually tested

* [ ] dart analyze passes

* [ ] Existing code is not overwritten

* [ ] No unnecessary files were created

* [ ] WORKING_BACKLOG updated

---

# Engineering Rules

1. One checkbox at a time.

2. One Antigravity prompt = One checkbox.

3. Every task ends with verification.

4. Never overwrite developer-owned files.

5. Never generate unnecessary abstractions.

6. Never let Antigravity perform Git operations.

7. Every GitHub issue must produce a user-facing outcome.

8. Never continue to the next issue until the current issue is fully verified.

---

# Workflow

WORKING_BACKLOG.md

↓

Pick first unchecked item

↓

Create strict contract prompt

↓

Execute

↓

Verify

↓

Mark complete

↓

Repeat

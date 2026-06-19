# Flutter Forge Working Backlog

## Current Focus

# Foundation Templates

## Design

- [x] Finalize Golden Project Template

### Golden Project Template v1

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

### Ownership Rules

Folders
- Inject every time

Foundation files
- Scaffold once

Business logic
- Developer owned forever

Flutter Forge
- Never overwrites developer code

---

## Implementation

### Session 1

- [ ] Scaffold app_exception.dart

- [ ] Scaffold api_result.dart

### Session 2

- [ ] Scaffold exception_mapper.dart

- [ ] Scaffold dio_client.dart

### Session 3

- [ ] Connect foundation templates with forge init

- [ ] Verify forge init end-to-end

- [ ] Verify existing files are never overwritten

- [ ] Verify dart analyze passes

---

## Upcoming

### Build Feature Generator

Pending

### Documentation

Pending

### Testing & Release

Pending

---

## Engineering Rules

1. One checkbox at a time.

2. One Antigravity prompt = One checkbox.

3. Never overwrite developer-owned files.

4. Never generate unnecessary abstractions.

5. Every task ends with verification.
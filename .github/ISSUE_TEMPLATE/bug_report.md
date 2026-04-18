---
name: Bug report
about: Report a defect or regression in Rune
title: "[bug] "
labels: bug
assignees: ''
---

## Describe the bug

> One-line summary of what's wrong.

## Reproduction

Provide the smallest `RuneView.source` string (and `data` map, if any) that
triggers the failure, plus the exact stack trace.

```dart
// RuneView.source
''' ... '''

// data
const <String, Object?>{ ... }
```

```
// Stack trace (paste verbatim)
```

## Expected behavior

What you expected Rune to render or do instead.

## Environment

- Rune version (from `pubspec.yaml`, or run `grep version pubspec.yaml`):
- Flutter version (from `flutter --version`):
- Platform (iOS / Android / Web / macOS / Windows / Linux):

## Additional context

Screenshots, related issues, or anything else that helps.

---
name: Bug report
about: Report a reproducible defect in Rune or one of its sibling bridges
title: "[bug] "
labels: bug
assignees: ''
---

## Summary

A clear one-sentence description of what's wrong.

## Minimal reproduction

Paste the exact `RuneView.source` string and `data` map that triggers the failure. Include the `RuneConfig` (defaults, or which bridges are applied).

```dart
RuneView(
  config: RuneConfig.defaults(),
  source: r'''
    // your source here
  ''',
  data: const {
    // your data here
  },
)
```

## Expected behavior

What you expected Rune to render or do.

## Actual behavior

What Rune actually rendered, threw, or logged. If a `RuneException` was raised, paste its full message including the caret-pointer block.

## Environment

- Rune version (e.g. `rune: ^1.15.0`):
- Flutter version (`flutter --version`):
- Dart SDK version:
- Platform (macOS / Windows / Linux / Android / iOS / web):
- Sibling bridges in use (if any): `rune_cupertino`, `rune_provider`, `rune_router`, `rune_responsive_sizer`.

## Additional context

Add any other context, stack traces, or screenshots here. If the bug only surfaces with a specific data shape, paste a minimal Map that reproduces it.

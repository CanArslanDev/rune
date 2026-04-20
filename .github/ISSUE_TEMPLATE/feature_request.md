---
name: Feature request
about: Propose a new widget, value, constant, extension, resolver arm, or imperative for Rune
title: "[feature] "
labels: enhancement
assignees: ''
---

## What you want to write

Paste the Rune source you want to be able to write. The more concrete, the better.

```
// example: what you want Rune to understand
SomeNewWidget(
  value: 42,
  onChanged: 'something',
)
```

## What Rune does today

Describe the current behavior: does it throw `UnregisteredBuilderException`? `ResolveException`? Something else?

## Scope

- [ ] New widget builder (one class from Flutter's SDK or a popular package).
- [ ] New value builder (a constructor or named factory).
- [ ] New constant group.
- [ ] New property extension (e.g. `.something` on a value).
- [ ] New resolver arm (new Dart syntax shape).
- [ ] New imperative bridge (top-level or `Foo.of(context)` flavor).
- [ ] Other (explain).

## Why

What does this unlock? Real use cases beat hypotheticals.

## Sibling bridge vs main-package

Third-party or framework-specific integrations (e.g. a Provider / go_router / Firebase pairing) typically ship as a separate `rune_<name>` package under `packages/`. Flutter SDK widgets that are already default-registered-shaped go in the main package. Which does this feel like?

## Additional context

Links to Flutter docs, related issues, prior art in other server-driven-UI packages, etc.

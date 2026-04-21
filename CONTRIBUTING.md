# Contributing to Rune

Thanks for your interest in contributing. This guide covers what you need to
know to work on Rune productively.

## Project overview

Rune is a Flutter package that interprets Dart widget-construction source
strings (e.g. `Column(children: [Text('hi')])`) into real Flutter widgets at
runtime. It does this by parsing the string with `package:analyzer`, walking
the resulting AST, and dispatching to registered builders that construct
ordinary Flutter widgets. There is no reflection, no `eval`, and no on-device
code generation — only interpretation of a constrained subset of Dart
expression syntax. That makes Rune compatible with Apple App Store and Google
Play review policies for dynamic UI.

## Getting started

- Clone: `git clone https://github.com/CanArslanDev/rune.git`
- Install: `flutter pub get`
- Test: `flutter test`
- Analyze: `flutter analyze`
- Toolchain: Dart `^3.4.0`, Flutter `>=3.22.0`
- If you touch shared code, also run `flutter test` and `flutter analyze`
  inside `packages/rune_responsive_sizer/`.

## Architecture at a glance

Rune enforces a unidirectional dependency flow. Each layer imports only
downstream layers:

```
dynamic_view -> config -> registries -> resolver -> parser -> analyzer
                              ^              |
                              |              v
                              +----- builders
```

The architecture test in `test/architecture/import_flow_test.dart` enforces
these boundaries — extending with a new layer requires extending the test.
Trace through `lib/src/dynamic_view.dart` to see how a `RuneView` renders
end-to-end.

## Adding a widget builder

Builders are `final`, stateless, and `const`-constructed. Put new widget
builders in `lib/src/builders/widgets/<name>_builder.dart`:

```dart
import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [FooBar] widgets from positional and named arguments.
final class FooBarBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const FooBarBuilder();

  @override
  String get typeName => 'FooBar';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final label = args.requirePositional<String>(0, source: 'FooBar');
    return FooBar(label: label, padding: args.get<double>('padding'));
  }
}
```

Register it in `lib/src/defaults/rune_defaults.dart` (inside
`registerWidgets`) if it should ship as a default; otherwise leave
registration to consumers. A unit test at
`test/builders/<name>_builder_test.dart` is required in the same commit —
use `test/_helpers/test_context.dart` to construct a canonical context.

## Adding a property extension

Property extensions (e.g. `10.px`) register handlers on
`ExtensionRegistry`. Prefer shipping them as a `RuneBridge` package so
consumers can opt in. See `packages/rune_responsive_sizer/` for the
canonical shape: a class implementing `RuneBridge` whose `registerInto`
installs one or more `RuneExtensionHandler`s, each validating the target
type and returning a resolved value.

## Documentation requirements

User-facing documentation lives in two surfaces that must stay in sync:

- `README.md` at the repo root: the 5-minute tour, API catalog,
  quickstart, bridge-packages table.
- `guides/*.md`: deeper, topic-focused companion guides
  (`getting-started`, `source-syntax`, `cookbook`, `bridges`,
  `devtools`, `troubleshooting`).

When you change behavior, syntax support, bridge configuration, or
the exception taxonomy, update **both** surfaces in the same
commit. The README is where someone first lands; the guides are
where they go when the README is not enough. Drift between the
two is how "the docs lie" bugs creep in.

Rule of thumb: if a change adds or modifies something a consumer
would write in their `RuneView.source` string, it belongs in
`guides/source-syntax.md` or `guides/cookbook.md`; if it changes
how a bridge package is set up, `guides/bridges.md`; if it affects
errors, `guides/troubleshooting.md`.

## Testing requirements

- TDD is the expected workflow: write a failing test, make it pass, commit.
- Every new public API ships with tests in the same commit — no "tests in a
  follow-up PR".
- Both gates are non-negotiable for every PR: `flutter test` green at the
  repo root (and in any sibling package you touched) AND `flutter analyze`
  reporting 0 issues under `very_good_analysis ^5.1.0`.
- Tests mirror source layout: a builder at
  `lib/src/builders/widgets/foo_builder.dart` gets a test at
  `test/builders/foo_builder_test.dart`.
- Integration smoke tests live under `test/integration/`. Architecture
  invariants live in `test/architecture/import_flow_test.dart`; extend it
  whenever you add a new layer or import boundary.

## Commit style

Rune uses [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` new user-visible behaviour
- `fix:` bug fix
- `refactor:` internal change with no behaviour delta
- `test:` test-only change
- `chore:` tooling, release plumbing
- `docs:` docs-only change

Subject line stays at or under 72 characters. One logical change per
commit — don't bundle a refactor and a feature. Write the commit body to
explain "why", not "what".

## Pull request checklist

Before opening a PR, verify:

- Tests added or updated for the new behaviour.
- `flutter analyze` reports 0 issues at the repo root (and in any sibling
  package you touched).
- `flutter test` passes at the repo root (and in any sibling package you
  touched).
- `test/architecture/import_flow_test.dart` still passes — if you added a
  layer, extend the guard in the same commit.
- `CHANGELOG.md` has an entry under `## [Unreleased]` for any user-visible
  change (skip for pure refactors, internal-only tests, or docs).

The PR template surfaces this checklist automatically.

## Reporting bugs

Open an issue using the bug report template
(`.github/ISSUE_TEMPLATE/bug_report.md`). A minimal reproduction — the
exact `RuneView.source` string and `data` map that triggers the failure —
shortens the round-trip significantly. Feature requests go through the
feature request template.

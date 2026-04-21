# rune_lint

Validation helpers for Rune source strings. Catches unregistered widgets, missing constants, typos, and parse errors at **test time** instead of at runtime in front of users.

## Install

```yaml
dev_dependencies:
  rune_lint: ^0.1.0
```

## Use inside a test

Wrap any Rune source string with `expectValidRuneSource` inside a `testWidgets`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';
import 'package:rune_lint/rune_lint.dart';

const homeSource = '''
  Column(children: [
    Text('Welcome'),
    Icon(Icons.shoping_cart),  // typo!
  ])
''';

void main() {
  testWidgets('home.rune is valid', (tester) async {
    await expectValidRuneSource(tester, homeSource, RuneConfig.defaults());
  });
}
```

The test fails with:

```
Expected valid Rune source, got 1 issue(s):
  - [resolveError] ResolveException: Unknown constant "Icons.shoping_cart"
    (did you mean "shopping_cart"?) ...
```

No more shipping the typo to production.

## When the data map matters

If the source references identifiers, pass them through `data:`:

```dart
testWidgets('profile.rune is valid', (tester) async {
  await expectValidRuneSource(
    tester,
    profileSource,
    RuneConfig.defaults(),
    data: const {'username': '', 'email': ''},
  );
});
```

Skipping `data:` surfaces every identifier as a `missingBinding` issue. That is often what you want at validation time; pass the data only for specific scenarios you want to validate end-to-end.

## Tolerating known-absent data

For source that relies on runtime state you do not want to fake in tests, tell the validator to ignore a specific category:

```dart
await expectValidRuneSource(
  tester,
  checkoutSource,
  RuneConfig.defaults(),
  ignoreKinds: const [RuneLintIssueKind.missingBinding],
);
```

The test now passes as long as every widget / value / constant is registered, regardless of whether the data keys exist. Useful for CI that runs before the host-side code that populates data is present.

## Low-level API

`validateRuneSource(tester, source, config, {data})` returns a `List<RuneLintIssue>` so you can do custom filtering / reporting / grouping. `expectValidRuneSource` is just a thin wrapper over it plus `fail()`.

Each `RuneLintIssue` has:

- `kind`: one of `parseError`, `unregistered`, `invalidArgument`, `missingBinding`, `resolveError`.
- `message`: the `toString()` of the underlying `RuneException`.
- `offendingSource`: the substring of the Rune source that triggered the issue.
- `line`, `column`: 1-based offsets into the source, when available.

## What this does NOT catch

- Errors that only happen at the **build phase** (e.g. a custom builder throwing `ArgumentError` when given a specific data value it did not anticipate).
- Network / platform failures from imperatives like `showDialog`.
- Runtime behavior of named events.

In other words: `rune_lint` catches "the source is shaped correctly, every name resolves, and nothing explodes in parse/resolve". Dynamic runtime behavior still needs its own tests.

## License

MIT. See [`LICENSE`](LICENSE).

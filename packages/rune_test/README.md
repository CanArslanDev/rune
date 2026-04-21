# rune_test

Test-ergonomics helpers and a `rune_format` CLI for Rune source.

## Install

```yaml
dev_dependencies:
  rune_test: ^0.1.0
```

## Test helpers

`pumpRuneView` wraps a `RuneView` in a minimal `MaterialApp` + `Scaffold` and settles the frame. Most tests that exercise source strings need roughly this harness every time; the helper trims it to one call.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:rune_test/rune_test.dart';

void main() {
  testWidgets('greeting renders', (tester) async {
    await pumpRuneView(
      tester,
      r"Text('Hello, $name!')",
      data: const {'name': 'Ali'},
    );
    expect(find.text('Hello, Ali!'), findsOneWidget);
  });
}
```

`expectRuneRenders` fuses the pump + assertion in one call:

```dart
testWidgets('greeting renders', (tester) async {
  await expectRuneRenders(
    tester,
    r"Text('Hello, $name!')",
    find.text('Hello, Ali!'),
    findsOneWidget,
    data: const {'name': 'Ali'},
  );
});
```

Both helpers accept the full `RuneView` surface (`config`, `data`, `onEvent`, `onError`, `fallback`). Pass a custom `wrap:` if you need a different chrome (`CupertinoApp`, `Localizations`, a `ProviderScope` root, etc.):

```dart
await pumpRuneView(
  tester,
  source,
  wrap: (child) => ProviderScope(child: MaterialApp(home: child)),
);
```

## Format CLI

The package ships a `rune_format` executable that wraps `formatRuneSource` for command-line use.

### Usage

```bash
# Print formatted output to stdout
dart run rune_test:rune_format path/to/source.rune

# Rewrite file in place
dart run rune_test:rune_format path/to/source.rune --write

# CI check: exit 1 if the file is not already formatted
dart run rune_test:rune_format path/to/source.rune --check

# Read from stdin
cat source.rune | dart run rune_test:rune_format -

# Override the 80-char break threshold
dart run rune_test:rune_format path/to/source.rune --line-length 100 --write
```

### Exit codes

- `0` on success (or when `--check` finds no formatting drift).
- `1` when `--check` finds the file is out of date.
- `64` (EX_USAGE) on command-line misuse.

### Wire into CI

```yaml
# .github/workflows/ci.yaml
- name: Check Rune source formatting
  run: dart run rune_test:rune_format lib/rune/home.rune --check
```

Fails the job when a source file has drifted from canonical format, in the same shape `dart format --output=none --set-exit-if-changed` uses.

## License

MIT. See [`LICENSE`](LICENSE).

# Troubleshooting

Common errors and how to read them. Every failure that Rune raises at parse / resolve / build time is a subtype of `RuneException`, caught by `RuneView.build()` and forwarded to `onError` (or the default debug error widget in its absence).

## The exception hierarchy

```
RuneException (sealed, abstract)
├── ParseException              Raised while analyzer is parsing the source.
├── ResolveException            Raised during AST walking.
├── UnregisteredBuilderException  Subtype of ResolveException. Unknown widget/value type.
├── ArgumentException           Raised by a builder when a required arg is missing or malformed.
└── BindingException            Raised when data lookup fails (unknown identifier).
```

Every exception carries:

- A `source` field with the offending Dart substring.
- A `message` describing what went wrong in human terms.
- An optional `location` (`SourceSpan`) pointing at the exact offset within the original source string.

Printing the exception (or seeing it in the default `_DefaultErrorView`) yields a caret-pointer block:

```
ResolveException: Unknown identifier "userNam" (not present in RuneDataContext)

  at line 3, column 11:
        Text(userNam)
             ^^^^^^^
```

The caret row points at the exact offending token. Great for surfacing typos.

## Catalog

### `UnregisteredBuilderException: No builder for "FooWidget"`

The source used a widget or value type that is not registered in the current `RuneConfig`. Causes:

- **Typo**: did you mean `Foo`? Rune's diagnostic adds a "did you mean ...?" hint for names close by Levenshtein distance.
- **Missing bridge**: the type belongs to a sibling bridge (e.g. `CupertinoButton` needs `CupertinoBridge`). Apply the bridge:

    ```dart
    final config = RuneConfig.defaults()
        .withBridges(const [CupertinoBridge()]);
    ```

- **Custom widget**: register your own builder:

    ```dart
    final config = RuneConfig.defaults();
    config.widgets.registerBuilder(const MyFooBarBuilder());
    ```

### `BindingException: Unknown identifier "xyz" (not present in RuneDataContext)`

The source referenced a bare identifier that isn't in the `data:` map. Typical fixes:

- Check the spelling against the map's keys (the diagnostic suggests close matches).
- If it's meant to be a closure parameter (e.g. inside `StatefulBuilder(builder: (state) => ...)`, or a `for (final item in items)` element), the inner scope shadows data; `state` inside the builder refers to the builder's bag, not a data key.

### `ResolveException: Expected data value "foo" to be a Map for dot-access, got <some non-Map type>`

The source wrote `foo.member` but `data['foo']` is not a `Map<String, Object?>`. Rune's dot-access expects a map (or a built-in whitelisted type). Options:

- Wrap the data in a map: `data: {'foo': {'member': ...}}`.
- Register a member accessor on the type: `config.members.registerProperty<Foo>('member', (f, _) => f.member)` (v1.17.0+).
- Access `foo` differently (maybe it's really a `String.length` property, not a custom type).

### `ResolveException: No built-in method "doSomething" on String`

The source called a method not in Rune's whitelist. The diagnostic includes did-you-mean suggestions drawn from the whitelisted methods for that type.

- If it's a typo, fix it (`.toUppercase()` -> `.toUpperCase()`).
- If you genuinely need a non-whitelisted method, register it via `config.members.registerMethod<YourType>(...)`.

### `ArgumentException: MyWidget requires "child" (missing)`

A builder expected a named argument and did not receive one. Add the argument to the source.

### `ParseException: ...`

`analyzer` could not parse the string as a valid Dart expression. Common causes:

- Unbalanced brackets / parentheses.
- Missing quote on a string literal.
- Trailing characters after the expression (Rune expects a single expression per source).
- Statements instead of expressions (no top-level `if`, `for`, `return`; those live inside collection literals or closure bodies).

## When the fallback renders

By default, `_DefaultErrorView` shows a Flutter-provided red error widget in debug and a silent `SizedBox.shrink()` in release. Customise:

```dart
RuneView(
  source: ...,
  config: ...,
  fallback: Container(
    padding: const EdgeInsets.all(16),
    color: Colors.red.shade50,
    child: const Text('Could not render this view.'),
  ),
  onError: (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack);
    myLogger.warning('Rune render failed: $error');
  },
)
```

`onError` fires for **every** failure (`RuneException` variants and unexpected throwables from the host's `onEvent` callback). Release builds should sink errors to telemetry; debug builds benefit from a visible fallback.

## DevTools tab shows an error

If `rune_devtools_extension` says **"Could not reach the host process"**, the host app most likely either:

- Has no `RuneView` mounted yet (the `ext.rune.inspect` service extension is lazy).
- Is running in release mode (`dart:developer.registerExtension` is compiled out).
- Has a VM service connection issue (restart `flutter run`).

See [devtools.md](devtools.md) for the full setup.

## When to open an issue

If you hit a diagnostic that is **wrong**, **confusing**, or **missing a caret pointer**, open a bug report with a minimal reproduction: the exact `source` string, the `data` map, and the `RuneConfig` setup. Rune's diagnostics are a feature; the project treats "bad error message" as a real bug.

Use the [bug report template](../.github/ISSUE_TEMPLATE/bug_report.md).

# Getting started

This guide takes you from zero to a running `RuneView` with data binding and event dispatch in about 10 minutes. It assumes you already have a Flutter project set up (`flutter create my_app` and the usual environment).

## 1. Install

Add `rune` to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  rune: ^1.18.0
```

Then:

```bash
flutter pub get
```

That is the entire install. `rune` ships with a single runtime dependency beyond Flutter: `package:analyzer`. No native plugins, no platform channels, no codegen step.

## 2. Your first `RuneView`

Open `lib/main.dart`. Paste:

```dart
import 'package:flutter/material.dart';
import 'package:rune/rune.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Hello, Rune')),
        body: Center(
          child: RuneView(
            config: RuneConfig.defaults(),
            source: "Text('Hello, world!')",
          ),
        ),
      ),
    );
  }
}
```

Run it. You see the text "Hello, world!" rendered inside the `RuneView`. The interesting part: the text you see was produced by parsing the string `"Text('Hello, world!')"` at runtime, walking its AST, and constructing a real `Text` widget. No reflection, no `eval`, no `dart:mirrors`.

## 3. Adding data binding

Real apps need to pass runtime values into the source. Update the widget:

```dart
RuneView(
  config: RuneConfig.defaults(),
  source: r"""
    Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Welcome, $userName'),
        Text('You have ${itemCount} items in your cart'),
      ],
    )
  """,
  data: const {
    'userName': 'Ali',
    'itemCount': 3,
  },
)
```

Two things to notice:

* The source uses Dart string interpolation (`$userName`, `${itemCount}`). `RuneView` reads these against the `data` map at render time. The leading `r` on the Dart string literal is important: without it, the Dart compiler would try to evaluate the `$` expressions.
* `data` is a flat `Map<String, Object?>`. Missing keys raise a `BindingException` at resolve time (useful for catching typos early).

Nested data works too:

```dart
data: const {
  'user': {
    'name': 'Ali',
    'email': 'ali@example.com',
  },
},
source: r"Text('${user.name} <${user.email}>')",
```

Dot-access traverses nested maps. Unknown keys yield `null` at the leaf level (Dart-style).

## 4. Handling interaction

Buttons in Rune source reference named events, and the host app handles them:

```dart
RuneView(
  config: RuneConfig.defaults(),
  source: """
    ElevatedButton(
      onPressed: 'submit',
      child: Text('Submit'),
    )
  """,
  onEvent: (name, [args]) {
    if (name == 'submit') {
      debugPrint('User tapped submit');
    }
  },
)
```

`onPressed: 'submit'` dispatches the string `'submit'` back through `onEvent` when tapped. This keeps the source pure (no side-effect code in strings) while leaving the host in full control of behavior.

For inputs that carry a value (`TextField`, `Switch`, `Slider`), the second argument is populated:

```dart
String username = '';

return RuneView(
  config: RuneConfig.defaults(),
  data: {'username': username},
  source: """
    TextField(
      value: username,
      onChanged: 'usernameChanged',
      labelText: 'Username',
    )
  """,
  onEvent: (name, [args]) {
    if (name == 'usernameChanged') {
      setState(() => username = args!.first as String);
    }
  },
);
```

Two-way binding: the `value:` argument reads the latest `username` from data on every rebuild, and `onChanged` pushes the new value back through `onEvent` so the host can update state.

## 5. Error handling

If the source is malformed, `RuneView` catches the exception and shows a fallback widget. You can hook in:

```dart
RuneView(
  config: RuneConfig.defaults(),
  source: 'NotAWidget()',
  onError: (error, stack) => debugPrint('Rune error: $error'),
  fallback: const Text('Something went wrong.'),
)
```

Rune's exceptions carry caret-pointer diagnostics that show the offending substring. See [troubleshooting.md](troubleshooting.md) for the full list.

## Next steps

- Read [Source syntax reference](source-syntax.md) for the complete list of what the source can contain.
- Browse [Cookbook](cookbook.md) for copy-paste patterns.
- Add a sibling bridge via [Bridges](bridges.md) if you need Cupertino widgets, Provider/ChangeNotifier, go_router, or percent-of-screen sizing.
- Install the [DevTools extension](devtools.md) to inspect live `RuneView`s while you work.

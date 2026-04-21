# Cookbook

Copy-paste recipes for common patterns. Every snippet is pure Rune source (the string passed to `RuneView.source`) paired with the minimal host-side wiring needed to run it.

## Two-way text binding

Host state -> source input -> host event handler -> host state update.

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

The same pattern works for `Switch(value:, onChanged:)`, `Checkbox(value:, onChanged:)`, and `Slider(value:, onChanged:)`.

## Conditional rendering

`if`-elements short-circuit inside list literals. Combine with runtime properties:

```
Column(children: [
  if (cart.items.isEmpty) Text('Your cart is empty'),
  if (cart.items.isNotEmpty)
    for (final item in cart.items)
      ListTile(title: Text(item.name)),
  if (cart.items.length >= 3)
    Text('Free shipping unlocked!',
         style: TextStyle(color: Color(0xFF2E7D32))),
])
```

For either-or branching: `if (cond) A else B`.

## Soft-disabled button via ternary event selection

Route the same button to a no-op event until a predicate is satisfied. The button stays enabled-looking; the host simply ignores the no-op:

```
ElevatedButton(
  onPressed: username.isEmpty ? 'noop' : 'save',
  child: Text('Save'),
)
```

Host:

```dart
onEvent: (name, [args]) {
  switch (name) {
    case 'save':
      submitForm();
    case 'noop':
      break; // intentional
  }
}
```

## Reactive counter with `rune_provider`

1. Add `rune_provider` to `dependencies` and apply its bridge.
2. Define the notifier on the host:

```dart
class CounterNotifier extends ChangeNotifier
    implements RuneReactiveNotifier {
  int _count = 0;
  void increment() { _count++; notifyListeners(); }

  @override
  Map<String, Object?> get state => {'count': _count};
}
```

3. Consume from source:

```
ChangeNotifierProvider(
  value: counter,
  child: Column(children: [
    Consumer(
      builder: (ctx, state, child) => Text('Count: ${state.count}'),
    ),
    ElevatedButton(
      onPressed: 'increment',
      child: Text('+1'),
    ),
  ]),
)
```

4. Handle `'increment'` on the host with `counter.increment()`.

## Percent-of-screen sizing with `rune_responsive_sizer`

Apply the bridge and use `.w`, `.h`, `.sp` inside any numeric slot:

```
Container(
  width: 80.w,
  height: 10.h,
  child: Text('Hi', style: TextStyle(fontSize: 16.sp)),
)
```

## Inline routing with `rune_router`

Declare a whole app-level routing structure from source:

```
GoRouterApp(
  router: GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (ctx, state) => Scaffold(
          body: ElevatedButton(
            onPressed: 'go-settings',
            child: Text('Settings'),
          ),
        ),
      ),
      GoRoute(
        path: '/settings',
        builder: (ctx, state) => Scaffold(body: Text('Settings page')),
      ),
    ],
  ),
)
```

Host holds a reference to the `GoRouter` and navigates from event handlers:

```dart
final router = GoRouter(/* same routes */);

onEvent: (name, [args]) {
  if (name == 'go-settings') router.go('/settings');
}
```

## Dialog from an event

```
ElevatedButton(
  onPressed: () => showDialog(
    context: ctx,
    builder: (ctx) => AlertDialog(
      title: Text('Confirm'),
      content: Text('Delete item?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(), child: Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(true), child: Text('Delete')),
      ],
    ),
  ),
  child: Text('Delete'),
)
```

The source-level `showDialog` is an imperative bridge routed through `RuneContext.flutterContext`. The `RuneView` must be mounted under a `MaterialApp` or similar for the context lookup to succeed.

## Stateful source with `StatefulBuilder`

No host wiring needed for the state bag:

```
StatefulBuilder(
  initial: {'count': 0},
  builder: (state) => Column(children: [
    Text('Count: ${state.count}'),
    ElevatedButton(
      onPressed: () => setState(() { state.count = state.count + 1; }),
      child: Text('+1'),
    ),
  ]),
)
```

`state` is mutable; assignment triggers rebuild inside the `setState` callback.

## Dispatch a value through an event

Events can carry typed values:

```
Slider(
  value: volume,
  onChanged: 'volumeChanged',
  min: 0,
  max: 100,
)
```

Host:

```dart
onEvent: (name, [args]) {
  if (name == 'volumeChanged') {
    setState(() => volume = args!.first as double);
  }
}
```

The framework passes the new slider value as the sole positional argument. Same pattern for every `onChanged:` callback.

## Custom type reached from source (v1.17.0+)

Register accessors without projecting through a `Map`:

```dart
final config = RuneConfig.defaults();
config.members
  ..registerProperty<User>('name', (u, _) => u.name)
  ..registerProperty<User>('email', (u, _) => u.email)
  ..registerMethod<User>('send', (u, args, _) {
    u.sendMessage(args.first as String);
    return null;
  });
```

Then from source:

```
Column(children: [
  Text(currentUser.name),
  Text(currentUser.email),
  ElevatedButton(
    onPressed: () => currentUser.send('hello'),
    child: Text('Say hi'),
  ),
])
```

Built-in whitelist types (`String`, `List`, `Map`, `ThemeData`, etc.) cannot be shadowed; custom types work cleanly.

## Deep link into nested data

Data is a free-form map. Chain dot-access arbitrarily:

```dart
data: const {
  'user': {
    'profile': {
      'displayName': 'Ali',
      'stats': {'posts': 42, 'followers': 1024},
    },
  },
},
source: r"""
  Column(children: [
    Text('${user.profile.displayName}'),
    Text('${user.profile.stats.posts} posts'),
    Text('${user.profile.stats.followers} followers'),
  ])
""",
```

Missing keys at the leaf return `null`.

## Show an error fallback

Rune catches any exception during parse / resolve / build and falls back:

```dart
RuneView(
  config: RuneConfig.defaults(),
  source: 'NotAWidget()',
  fallback: const Center(child: Text('Something went wrong')),
  onError: (error, stack) => debugPrint('Rune: $error'),
)
```

The error sink receives both `RuneException` variants and any Flutter runtime error. See [troubleshooting.md](troubleshooting.md) for the exception hierarchy.

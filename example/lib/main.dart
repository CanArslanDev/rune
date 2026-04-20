import 'package:flutter/material.dart';
import 'package:rune/rune.dart';
import 'package:rune_provider/rune_provider.dart';
import 'package:rune_responsive_sizer/rune_responsive_sizer.dart';

void main() => runApp(const RuneExampleApp());

/// Root of the Rune demo app.
///
/// Hosts four `RuneView`s inside a `DefaultTabController` + `TabBar`:
///
/// 1. **Shopping cart** - `if` / `for` elements, runtime methods,
///    runtime properties, comparisons, deep dot-paths, `ListTile`,
///    and `Divider`.
/// 2. **Profile form** - `TextField`, `Switch`, `Checkbox`, two-way
///    data binding via named events, conditional validation preview,
///    ternary event-name selector.
/// 3. **Reactive counter** - `rune_provider`'s
///    `ChangeNotifierProvider` + `Consumer` + `Selector` driving a
///    `RuneReactiveNotifier`-backed counter. Demonstrates reactive
///    Map-projected state consumed from Rune source.
/// 4. **Responsive layout** - `rune_responsive_sizer`'s `.w` / `.h`
///    / `.sp` percent-of-screen extensions applied to widget sizes
///    and text styles.
///
/// Each tab's `RuneView` receives only the data slice it needs, and
/// tab interactions are isolated: cart mutations don't touch the
/// form state or the counter, and vice versa.
class RuneExampleApp extends StatefulWidget {
  /// Creates the demo app.
  const RuneExampleApp({super.key});

  @override
  State<RuneExampleApp> createState() => _RuneExampleAppState();
}

class _RuneExampleAppState extends State<RuneExampleApp> {
  // Cart-tab state.
  final List<Map<String, Object?>> _cartItems = <Map<String, Object?>>[
    <String, Object?>{'id': 1, 'name': 'wireless mouse', 'price': 19},
    <String, Object?>{'id': 2, 'name': 'mechanical keyboard', 'price': 129},
    <String, Object?>{'id': 3, 'name': '27" monitor', 'price': 349},
    <String, Object?>{'id': 4, 'name': 'usb-c hub', 'price': 45},
  ];

  // Form-tab state.
  String _username = '';
  String _bio = '';
  bool _notificationsEnabled = true;
  bool _subscribed = false;

  // Reactive-tab state (owned by the notifier below).
  final _CounterNotifier _counter = _CounterNotifier();

  int get _subtotal =>
      _cartItems.fold<int>(0, (sum, item) => sum + (item['price']! as int));

  @override
  void dispose() {
    _counter.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.maybeOf(context)
      ?..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleCartEvent(String name, [List<Object?>? args]) {
    switch (name) {
      case 'remove':
        if (_cartItems.isNotEmpty) {
          setState(() => _cartItems.removeAt(0));
        }
      case 'checkout':
        _showSnack('Checkout complete. Cart cleared.');
        setState(_cartItems.clear);
      default:
        debugPrint('Rune (cart) event: $name args=$args');
    }
  }

  void _handleFormEvent(String name, [List<Object?>? args]) {
    final first = args != null && args.isNotEmpty ? args.first : null;
    switch (name) {
      case 'usernameChanged':
        setState(() => _username = (first as String?) ?? '');
      case 'bioChanged':
        setState(() => _bio = (first as String?) ?? '');
      case 'notificationsChanged':
        setState(() => _notificationsEnabled = (first as bool?) ?? false);
      case 'subscribedChanged':
        setState(() => _subscribed = (first as bool?) ?? false);
      case 'save':
        _showSnack('Profile saved for $_username.');
      case 'noop':
        break;
      default:
        debugPrint('Rune (form) event: $name args=$args');
    }
  }

  void _handleReactiveEvent(String name, [List<Object?>? args]) {
    switch (name) {
      case 'increment':
        _counter.increment();
      case 'decrement':
        _counter.decrement();
      case 'reset':
        _counter.reset();
      default:
        debugPrint('Rune (reactive) event: $name args=$args');
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = RuneConfig.defaults();
    final providerConfig =
        RuneConfig.defaults().withBridges(const [ProviderBridge()]);
    final responsiveConfig = RuneConfig.defaults()
        .withBridges(const [ResponsiveSizerBridge()]);
    return MaterialApp(
      title: 'Rune Demo',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Rune Demo'),
            bottom: const TabBar(
              isScrollable: true,
              tabs: <Widget>[
                Tab(icon: Icon(Icons.shopping_cart), text: 'Cart'),
                Tab(icon: Icon(Icons.person), text: 'Profile'),
                Tab(icon: Icon(Icons.sync), text: 'Reactive'),
                Tab(icon: Icon(Icons.aspect_ratio), text: 'Responsive'),
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              RuneView(
                source: _cartSource,
                config: config,
                data: <String, Object?>{
                  'cart': <String, Object?>{
                    'items': _cartItems,
                    'subtotal': _subtotal,
                  },
                },
                onEvent: _handleCartEvent,
                fallback: const Center(child: Text('Cart failed to render')),
                onError: (Object error, StackTrace _) {
                  debugPrint('Rune (cart) error: $error');
                },
              ),
              RuneView(
                source: _formSource,
                config: config,
                data: <String, Object?>{
                  'username': _username,
                  'bio': _bio,
                  'notificationsEnabled': _notificationsEnabled,
                  'subscribed': _subscribed,
                },
                onEvent: _handleFormEvent,
                fallback: const Center(child: Text('Form failed to render')),
                onError: (Object error, StackTrace _) {
                  debugPrint('Rune (form) error: $error');
                },
              ),
              RuneView(
                source: _reactiveSource,
                config: providerConfig,
                data: <String, Object?>{'counter': _counter},
                onEvent: _handleReactiveEvent,
                fallback:
                    const Center(child: Text('Reactive tab failed to render')),
                onError: (Object error, StackTrace _) {
                  debugPrint('Rune (reactive) error: $error');
                },
              ),
              RuneView(
                source: _responsiveSource,
                config: responsiveConfig,
                data: const <String, Object?>{},
                fallback: const Center(
                  child: Text('Responsive tab failed to render'),
                ),
                onError: (Object error, StackTrace _) {
                  debugPrint('Rune (responsive) error: $error');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Rune sources ----------

  static const String _cartSource = r'''
    Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Cart (${cart.items.length} items)',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          if (cart.items.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'Your cart is empty.',
                  style: TextStyle(color: Color(0xFF757575), fontSize: 16),
                ),
              ),
            ),
          for (final item in cart.items)
            ListTile(
              leading: Icon(Icons.shopping_bag),
              title: Text(item.name.toUpperCase()),
              subtitle: Text('\$${item.price}'),
              trailing: TextButton(
                onPressed: 'remove',
                child: Text('Remove'),
              ),
            ),
          Divider(),
          if (cart.items.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal: \$${cart.subtotal}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                ElevatedButton(
                  onPressed: 'checkout',
                  child: Text('Checkout'),
                ),
              ],
            ),
          if (cart.items.length >= 3)
            Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'Free shipping unlocked!',
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    )
  ''';

  static const String _formSource = '''
    Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Edit your profile',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          TextField(
            value: username,
            onChanged: 'usernameChanged',
            labelText: 'Username',
          ),
          SizedBox(height: 12),
          TextField(
            value: bio,
            onChanged: 'bioChanged',
            labelText: 'Bio',
            maxLines: 3,
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Switch(
                value: notificationsEnabled,
                onChanged: 'notificationsChanged',
              ),
              SizedBox(width: 8),
              Text('Notifications'),
              Spacer(),
            ],
          ),
          Row(
            children: [
              Checkbox(
                value: subscribed,
                onChanged: 'subscribedChanged',
              ),
              SizedBox(width: 8),
              Text('Subscribe to newsletter'),
              Spacer(),
            ],
          ),
          Divider(),
          if (username.isEmpty)
            Text(
              'Username is required.',
              style: TextStyle(color: Color(0xFFC62828)),
            ),
          if (username.isNotEmpty && bio.length < 10)
            Text(
              'Bio should be at least 10 characters.',
              style: TextStyle(color: Color(0xFFEF6C00)),
            ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: username.isEmpty ? 'noop' : 'save',
            child: Text('Save'),
          ),
        ],
      ),
    )
  ''';

  static const String _reactiveSource = r'''
    Padding(
      padding: EdgeInsets.all(16),
      child: ChangeNotifierProvider(
        value: counter,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Reactive counter',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Consumer(
              builder: (ctx, state, child) => Text(
                'Count: ${state.count}',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(height: 8),
            Selector(
              selector: (ctx, state) => state.parity,
              builder: (ctx, parity, child) => Text(
                'Parity: $parity (rebuilds only when parity flips)',
                style: TextStyle(color: Color(0xFF455A64)),
              ),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: 'decrement',
                  child: Text('-1'),
                ),
                SizedBox(width: 12),
                ElevatedButton(
                  onPressed: 'increment',
                  child: Text('+1'),
                ),
                SizedBox(width: 12),
                OutlinedButton(
                  onPressed: 'reset',
                  child: Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    )
  ''';

  static const String _responsiveSource = '''
    Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Percent-of-screen sizing',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(
            'Widget widths below scale with the viewport via .w / .h / .sp.',
            style: TextStyle(fontSize: 12.sp, color: Color(0xFF546E7A)),
          ),
          SizedBox(height: 16),
          Container(
            width: 80.w,
            height: 8.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color(0xFFE8EAF6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '80% width / 8% height',
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
          SizedBox(height: 12),
          Container(
            width: 50.w,
            height: 6.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color(0xFFD1C4E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('50% width / 6% height'),
          ),
          SizedBox(height: 12),
          Container(
            width: 30.w,
            height: 4.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color(0xFFB39DDB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('30% / 4%', style: TextStyle(fontSize: 12.sp)),
          ),
        ],
      ),
    )
  ''';
}

/// A `ChangeNotifier` that exposes its state as a `Map` so Rune
/// source can dot-access the count directly.
///
/// Implementing `RuneReactiveNotifier` keeps the host-side Dart code
/// idiomatic (typed getters / explicit methods) while still bridging
/// individual fields into Rune's property resolver on each rebuild.
class _CounterNotifier extends ChangeNotifier
    implements RuneReactiveNotifier {
  int _count = 0;

  void increment() {
    _count += 1;
    notifyListeners();
  }

  void decrement() {
    _count -= 1;
    notifyListeners();
  }

  void reset() {
    _count = 0;
    notifyListeners();
  }

  @override
  Map<String, Object?> get state => <String, Object?>{
        'count': _count,
        'parity': _count.isEven ? 'even' : 'odd',
      };
}

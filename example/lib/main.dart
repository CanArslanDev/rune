import 'package:flutter/material.dart';
import 'package:rune/rune.dart';

void main() => runApp(const RuneExampleApp());

/// Root of the Rune demo app.
///
/// Hosts two `RuneView`s inside a `DefaultTabController` + `TabBar`:
///
/// 1. **Shopping cart** — exercises `if`-elements, `for`-elements over
///    list-of-maps, ternary-free conditional branches, runtime methods
///    (`toUpperCase`), runtime properties (`.length`, `.isEmpty`,
///    `.isNotEmpty`), arithmetic comparison (`>=`), deep dot-path
///    interpolation, `ListTile`, and `Divider`.
/// 2. **Profile form** — exercises `TextField`, `Switch`, `Checkbox`,
///    `Spacer`, two-way data binding via named events, conditional
///    validation preview with `&&` / `!` / `<`, and a ternary event-name
///    selector so the Save button is softly disabled until valid.
///
/// Both tabs share one `_RuneExampleAppState`; each `RuneView` receives
/// a `data` map scoped to its own slice. Cart mutations don't touch the
/// form state and vice versa.
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

  int get _subtotal =>
      _cartItems.fold<int>(0, (sum, item) => sum + (item['price']! as int));

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

  @override
  Widget build(BuildContext context) {
    final config = RuneConfig.defaults();
    return MaterialApp(
      title: 'Rune v0.2.0+ Demo',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Rune v0.2.0+ Demo'),
            bottom: const TabBar(
              tabs: <Widget>[
                Tab(icon: Icon(Icons.shopping_cart), text: 'Cart'),
                Tab(icon: Icon(Icons.person), text: 'Profile'),
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
}

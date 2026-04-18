import 'package:flutter/material.dart';
import 'package:rune/rune.dart';

void main() => runApp(const RuneExampleApp());

/// Root of the Rune demo app. Renders a single source string through
/// [RuneView] that exercises the v0.1.0 feature surface: Scaffold +
/// AppBar chrome, Column/Row/Padding/SizedBox layout, Text with
/// string interpolation including deep dot-path (`${user.profile.tier}`),
/// for-elements iterating `cart.items`, nested Card/Padding/Row tiles,
/// TextButton and ElevatedButton with named events, and BoxDecoration
/// with BorderRadius, TextStyle, and hex `Color` value builders.
class RuneExampleApp extends StatefulWidget {
  /// Creates the demo app.
  const RuneExampleApp({super.key});

  @override
  State<RuneExampleApp> createState() => _RuneExampleAppState();
}

class _RuneExampleAppState extends State<RuneExampleApp> {
  final List<String> _log = <String>[];

  void _handleEvent(String name, [List<Object?>? args]) {
    setState(() {
      _log.insert(0, 'event: $name');
      if (_log.length > 5) _log.removeLast();
    });
    debugPrint('Rune event: $name  args=$args');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rune v0.1.0 Demo',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: RuneView(
        source: _source,
        config: RuneConfig.defaults(),
        data: <String, Object?>{
          'user': const <String, Object?>{
            'name': 'Ali',
            'profile': <String, Object?>{
              'tier': 'Gold',
            },
          },
          'cart': const <String, Object?>{
            'items': <Map<String, Object?>>[
              <String, Object?>{'title': 'Wireless Mouse', 'price': 19},
              <String, Object?>{'title': 'Mechanical Keyboard', 'price': 129},
              <String, Object?>{'title': '27" Monitor', 'price': 349},
            ],
          },
          'log': _log,
        },
        onEvent: _handleEvent,
        fallback: const Scaffold(
          body: Center(child: Text('Failed to render')),
        ),
        onError: (Object error, StackTrace _) {
          debugPrint('Rune error: $error');
        },
      ),
    );
  }

  static const String _source = r"""
    Scaffold(
      appBar: AppBar(
        title: Text('Rune v0.1.0 Demo'),
        backgroundColor: Color(0xFF3F51B5),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Hello, ${user.name}!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Membership tier: ${user.profile.tier}',
              style: TextStyle(color: Color(0xFF424242)),
            ),
            SizedBox(height: 16),
            Text(
              'Your cart',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            for (final item in cart.items)
              Card(
                elevation: 2,
                margin: EdgeInsets.symmetric(vertical: 4),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.title),
                      Text(
                        '\$${item.price}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: 'clear',
                  child: Text('Clear'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: 'checkout',
                  child: Text('Checkout'),
                ),
              ],
            ),
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Event log',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  for (final entry in log) Text(entry),
                ],
              ),
            ),
          ],
        ),
      ),
    )
  """;
}

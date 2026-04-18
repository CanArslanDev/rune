import 'package:flutter/material.dart';
import 'package:rune/rune.dart';

void main() => runApp(const RuneExampleApp());

/// Root of the Phase 2a demo app. Renders a string through [RuneView] with
/// data binding, constants, and string interpolation all live.
class RuneExampleApp extends StatelessWidget {
  /// Creates the demo app.
  const RuneExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rune — Phase 2a Demo',
      home: Scaffold(
        appBar: AppBar(title: const Text('Rune — Phase 2a Demo')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: RuneView(
            source: _source,
            config: RuneConfig.defaults(),
            data: const {
              'userName': 'Ali',
              'itemCount': 7,
            },
            fallback: const Text('Failed to render'),
            onError: (error, _) => debugPrint('Rune error: $error'),
          ),
        ),
      ),
    );
  }

  static const String _source = r"""
    Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hello, $userName!'),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(12),
          child: Text('You have ${itemCount} items in your cart.'),
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Left aligned'),
            Text('Right aligned'),
          ],
        ),
      ],
    )
  """;
}

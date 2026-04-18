import 'package:flutter/material.dart';
import 'package:rune/rune.dart';

void main() => runApp(const RuneExampleApp());

/// Root of the Phase 1 demo app. Renders the [_source] string through a
/// [RuneView] with the default Rune configuration.
class RuneExampleApp extends StatelessWidget {
  /// Creates the demo app.
  const RuneExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rune — Phase 1 Demo',
      home: Scaffold(
        appBar: AppBar(title: const Text('Rune — Phase 1 Demo')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: RuneView(
            source: _source,
            config: RuneConfig.defaults(),
            fallback: const Text('Failed to render'),
            onError: (error, _) => debugPrint('Rune error: $error'),
          ),
        ),
      ),
    );
  }

  static const String _source = """
    Column(children: [
      Text('Hello from a string'),
      SizedBox(height: 12),
      Container(
        padding: EdgeInsets.all(12),
        child: Text('I am inside a padded Container'),
      ),
      SizedBox(height: 12),
      Row(children: [
        Text('Left'),
        SizedBox(width: 20),
        Text('Right'),
      ]),
    ])
  """;
}

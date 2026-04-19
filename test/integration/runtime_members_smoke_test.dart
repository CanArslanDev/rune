import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('Runtime members smoke — built-in props and whitelisted methods', () {
    testWidgets('renders String method chain: name.trim().toUpperCase()',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          RuneView(
            source: 'Text(name.trim().toUpperCase())',
            config: RuneConfig.defaults(),
            data: const {'name': '  ali  '},
          ),
        ),
      );
      expect(find.text('ALI'), findsOneWidget);
    });

    testWidgets('conditionals compose with built-in properties',
        (tester) async {
      // The Rune source is a raw Dart string so `${items.length}` is a
      // Rune-level interpolation, NOT Dart interpolation at compile time.
      const source = r'''
        Column(
          children: [
            if (items.isNotEmpty) Text('Count: ${items.length}'),
            if (items.isEmpty) Text('Nothing to show'),
          ],
        )
      ''';

      // Variant 1: non-empty items → count visible, "Nothing" hidden.
      await tester.pumpWidget(
        _wrap(
          RuneView(
            source: source,
            config: RuneConfig.defaults(),
            data: const {
              'items': [1, 2, 3],
            },
          ),
        ),
      );
      expect(find.text('Count: 3'), findsOneWidget);
      expect(find.text('Nothing to show'), findsNothing);

      // Variant 2: empty items → "Nothing" visible, count hidden.
      await tester.pumpWidget(
        _wrap(
          RuneView(
            source: source,
            config: RuneConfig.defaults(),
            data: const {
              'items': <Object?>[],
            },
          ),
        ),
      );
      expect(find.text('Nothing to show'), findsOneWidget);
      expect(find.text('Count: 0'), findsNothing);
    });

    testWidgets('event dispatch gated by runtime method predicate',
        (tester) async {
      const source = '''
        ElevatedButton(
          onPressed: username.isEmpty ? 'noop' : 'submit',
          child: Text(submitted ? 'Done' : 'Submit'),
        )
      ''';

      String? captured;
      await tester.pumpWidget(
        _wrap(
          RuneView(
            source: source,
            config: RuneConfig.defaults(),
            data: const {
              'username': 'ali',
              'submitted': false,
            },
            onEvent: (name, [args]) {
              captured = name;
            },
          ),
        ),
      );

      expect(find.text('Submit'), findsOneWidget);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(
        captured,
        'submit',
        reason: "ternary picked 'submit' because username.isEmpty is false",
      );
    });

    testWidgets('List contains() gates a widget via ternary', (tester) async {
      const source =
          "Text(tags.contains('vip') ? 'VIP customer' : 'Standard')";

      await tester.pumpWidget(
        _wrap(
          RuneView(
            source: source,
            config: RuneConfig.defaults(),
            data: const {
              'tags': ['new', 'vip', 'active'],
            },
          ),
        ),
      );
      expect(find.text('VIP customer'), findsOneWidget);
    });
  });
}

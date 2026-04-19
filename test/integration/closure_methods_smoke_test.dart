import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('Phase A.3 smoke: closure-accepting collection methods via RuneView',
      () {
    testWidgets(
      '.map builds a widget list consumed as Column.children',
      (tester) async {
        // `items.map((i) => Text(i))` is a closure-driven build of the
        // children list. Rune materialises .map straight into a List, so
        // the trailing Dart-idiomatic `.toList()` is not needed here.
        const source = '''
          Column(children: items.map((i) => Text(i)))
        ''';
        await tester.pumpWidget(
          _wrap(
            RuneView(
              source: source,
              config: RuneConfig.defaults(),
              data: const {
                'items': ['a', 'b', 'c'],
              },
            ),
          ),
        );
        expect(find.text('a'), findsOneWidget);
        expect(find.text('b'), findsOneWidget);
        expect(find.text('c'), findsOneWidget);
      },
    );

    testWidgets(
      '.where filters upstream; .map builds widgets from the survivors',
      (tester) async {
        // Keep only strings whose length exceeds 2, then map each into a
        // Text. In the fixture below only "ccc" satisfies the predicate.
        // Rune's .map returns a materialised List directly, so no
        // trailing .toList() call is needed.
        const source = '''
          Column(
            children:
                items.where((i) => i.length > 2).map((i) => Text(i)),
          )
        ''';
        await tester.pumpWidget(
          _wrap(
            RuneView(
              source: source,
              config: RuneConfig.defaults(),
              data: const {
                'items': ['a', 'bb', 'ccc', 'd'],
              },
            ),
          ),
        );
        expect(find.text('ccc'), findsOneWidget);
        expect(find.text('a'), findsNothing);
        expect(find.text('bb'), findsNothing);
        expect(find.text('d'), findsNothing);
      },
    );

    testWidgets(
      '.fold computes a sum displayed inside a string interpolation',
      (tester) async {
        // `prices.fold(0, (sum, p) => sum + p)` totals the numbers; the
        // surrounding interpolation embeds the result in the Text.
        const source = r'''
          Text('Total: ${prices.fold(0, (sum, p) => sum + p)}')
        ''';
        await tester.pumpWidget(
          _wrap(
            RuneView(
              source: source,
              config: RuneConfig.defaults(),
              data: const {
                'prices': [10, 20, 30],
              },
            ),
          ),
        );
        expect(find.text('Total: 60'), findsOneWidget);
      },
    );
  });
}

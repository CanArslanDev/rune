import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('Phase B smoke: block-body closures via RuneView', () {
    testWidgets(
      'block-body closure used as .map callback with local + return',
      (tester) async {
        // A .map callback whose closure body is a full { ... } block:
        // declares a local via string interpolation, returns a Text.
        // Drives data-through-closure-parameter-into-block-scope
        // end-to-end. (String concatenation via `+` is deliberately
        // unsupported in Rune - interpolation is the idiomatic path.)
        const source = r'''
          Column(
            children: items.map((item) {
              final label = '$item!';
              return Text(label);
            }),
          )
        ''';
        await tester.pumpWidget(
          _wrap(
            RuneView(
              source: source,
              config: RuneConfig.defaults(),
              data: const {
                'items': ['a', 'b'],
              },
            ),
          ),
        );
        expect(find.text('a!'), findsOneWidget);
        expect(find.text('b!'), findsOneWidget);
      },
    );

    testWidgets(
      'block-body closure with if-statement controlling the return value',
      (tester) async {
        // prices.map((p) { if (p > 100) return 'expensive'; return 'cheap'; })
        // Exercises the IfStatement arm + early return inside a block.
        const source = '''
          Text(prices.map((p) {
            if (p > 100) {
              return 'expensive';
            }
            return 'cheap';
          }).join(', '))
        ''';
        await tester.pumpWidget(
          _wrap(
            RuneView(
              source: source,
              config: RuneConfig.defaults(),
              data: const {
                'prices': [50, 150],
              },
            ),
          ),
        );
        expect(find.text('cheap, expensive'), findsOneWidget);
      },
    );

    testWidgets(
      'block-body closure declares and reassigns a local before returning',
      (tester) async {
        // Exercises var-declaration + assignment + runtime .toString()
        // together through a .map closure.
        const source = '''
          Text(items.map((i) {
            var doubled = i * 2;
            doubled = doubled + 1;
            return doubled.toString();
          }).join(','))
        ''';
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
        expect(find.text('3,5,7'), findsOneWidget);
      },
    );
  });
}

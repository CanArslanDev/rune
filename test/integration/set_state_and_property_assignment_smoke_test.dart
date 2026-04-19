import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('Phase D smoke: setState sugar + property-access assignment', () {
    testWidgets(
      'counter with setState(() { state.counter = state.counter + 1; })',
      (tester) async {
        const source = r'''
          StatefulBuilder(
            initial: {'counter': 0},
            builder: (state) => Column(
              children: [
                Text('Count: ${state.counter}'),
                ElevatedButton(
                  onPressed: () => setState(() {
                    state.counter = state.counter + 1;
                  }),
                  child: Text('Inc'),
                ),
              ],
            ),
          )
        ''';
        await tester.pumpWidget(
          _wrap(
            RuneView(
              source: source,
              config: RuneConfig.defaults(),
            ),
          ),
        );
        expect(find.text('Count: 0'), findsOneWidget);

        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();
        expect(find.text('Count: 1'), findsOneWidget);

        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();
        expect(find.text('Count: 2'), findsOneWidget);
      },
    );

    testWidgets(
      'TextField driven by direct property assignment state.text = v',
      (tester) async {
        const source = r'''
          StatefulBuilder(
            initial: {'text': ''},
            builder: (state) => Column(
              children: [
                TextField(
                  value: state.text,
                  onChanged: (v) => state.text = v,
                ),
                Text('You typed: ${state.text}'),
              ],
            ),
          )
        ''';
        await tester.pumpWidget(
          _wrap(
            RuneView(
              source: source,
              config: RuneConfig.defaults(),
            ),
          ),
        );
        expect(find.text('You typed: '), findsOneWidget);

        await tester.enterText(find.byType(TextField), 'hello');
        await tester.pumpAndSettle();
        expect(find.text('You typed: hello'), findsOneWidget);
      },
    );

    testWidgets(
      'multiple mutations in one setState closure',
      (tester) async {
        const source = r'''
          StatefulBuilder(
            initial: {'a': 0, 'b': 0},
            builder: (state) => Column(
              children: [
                Text('A: ${state.a}, B: ${state.b}'),
                ElevatedButton(
                  onPressed: () => setState(() {
                    state.a = 10;
                    state.b = 20;
                  }),
                  child: Text('Set'),
                ),
              ],
            ),
          )
        ''';
        await tester.pumpWidget(
          _wrap(
            RuneView(
              source: source,
              config: RuneConfig.defaults(),
            ),
          ),
        );
        expect(find.text('A: 0, B: 0'), findsOneWidget);

        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();
        expect(find.text('A: 10, B: 20'), findsOneWidget);
      },
    );
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('Phase C smoke: source-level state via StatefulBuilder', () {
    testWidgets(
      'counter: tap ElevatedButton increments source-managed state',
      (tester) async {
        const source = r'''
          StatefulBuilder(
            initial: {'counter': 0},
            builder: (state) => Column(
              children: [
                Text('Count: ${state.counter}'),
                ElevatedButton(
                  onPressed: () =>
                      state.set('counter', state.counter + 1),
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
      'form: TextField + Checkbox + Reset button all driven by RuneState',
      (tester) async {
        const source = r'''
          StatefulBuilder(
            initial: {'text': '', 'agreed': false},
            builder: (state) => Column(
              children: [
                TextField(
                  value: state.text,
                  onChanged: (v) => state.set('text', v),
                ),
                Checkbox(
                  value: state.agreed,
                  onChanged: (v) => state.set('agreed', v),
                ),
                Text('text=${state.text}'),
                Text('agreed=${state.agreed}'),
                ElevatedButton(
                  onPressed: () =>
                      state.setMany({'text': '', 'agreed': false}),
                  child: Text('Reset'),
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
        expect(find.text('text='), findsOneWidget);
        expect(find.text('agreed=false'), findsOneWidget);

        await tester.enterText(find.byType(TextField), 'hello');
        await tester.pumpAndSettle();
        expect(find.text('text=hello'), findsOneWidget);

        await tester.tap(find.byType(Checkbox));
        await tester.pumpAndSettle();
        expect(find.text('agreed=true'), findsOneWidget);

        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();
        expect(find.text('text='), findsOneWidget);
        expect(find.text('agreed=false'), findsOneWidget);
      },
    );

    testWidgets(
      'conditional rendering: if-element reacts to state changes',
      (tester) async {
        const source = '''
          StatefulBuilder(
            initial: {'show': false},
            builder: (state) => Column(
              children: [
                ElevatedButton(
                  onPressed: () => state.set('show', true),
                  child: Text('Show'),
                ),
                if (state.show) Text('Visible!'),
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
        expect(find.text('Visible!'), findsNothing);

        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();
        expect(find.text('Visible!'), findsOneWidget);
      },
    );
  });
}

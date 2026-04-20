import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';

// Wraps [child] in a MaterialApp + Scaffold so Material widgets get
// the ancestors they require.
Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: child),
    );

void main() {
  group('v1.8.0 smoke: DataTable + ExpansionTile + Stepper', () {
    testWidgets(
      'DataTable renders column headings and cell values from source',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            SingleChildScrollView(
              child: RuneView(
                source: '''
                  DataTable(
                    columns: [
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Age'), numeric: true),
                    ],
                    rows: [
                      DataRow(cells: [
                        DataCell(Text('Alice')),
                        DataCell(Text('30')),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('Bob')),
                        DataCell(Text('42')),
                      ]),
                    ],
                  )
                ''',
                config: RuneConfig.defaults(),
              ),
            ),
          ),
        );
        expect(find.byType(DataTable), findsOneWidget);
        expect(find.text('Name'), findsOneWidget);
        expect(find.text('Age'), findsOneWidget);
        expect(find.text('Alice'), findsOneWidget);
        expect(find.text('Bob'), findsOneWidget);
        expect(find.text('30'), findsOneWidget);
        expect(find.text('42'), findsOneWidget);
      },
    );

    testWidgets(
      'ExpansionTile reveals its children when tapped',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            RuneView(
              source: '''
                ExpansionTile(
                  title: Text('Advanced'),
                  children: [
                    Text('hidden-child'),
                  ],
                )
              ''',
              config: RuneConfig.defaults(),
            ),
          ),
        );
        expect(find.text('Advanced'), findsOneWidget);
        expect(find.text('hidden-child'), findsNothing);
        await tester.tap(find.text('Advanced'));
        await tester.pumpAndSettle();
        expect(find.text('hidden-child'), findsOneWidget);
      },
    );

    testWidgets(
      'Stepper renders steps and dispatches onStepContinue',
      (tester) async {
        final fired = <String>[];
        await tester.pumpWidget(
          _wrap(
            RuneView(
              source: '''
                Stepper(
                  steps: [
                    Step(title: Text('First'), content: Text('body1')),
                    Step(title: Text('Second'), content: Text('body2')),
                  ],
                  currentStep: 0,
                  onStepContinue: 'next',
                  onStepCancel: 'back',
                )
              ''',
              config: RuneConfig.defaults(),
              onEvent: (name, [args]) => fired.add(name),
            ),
          ),
        );
        expect(find.byType(Stepper), findsOneWidget);
        expect(find.text('First'), findsOneWidget);
        expect(find.text('Second'), findsOneWidget);
        // The vertical Stepper renders two control buttons for the
        // current step's body (the "continue" and "cancel" localized
        // controls). Tap the first (continue) button and verify the
        // bound `next` event fires.
        final controls = find.descendant(
          of: find.byType(Stepper),
          matching: find.byType(TextButton),
        );
        expect(controls, findsWidgets);
        await tester.tap(controls.first);
        await tester.pumpAndSettle();
        expect(fired, contains('next'));
      },
    );
  });
}

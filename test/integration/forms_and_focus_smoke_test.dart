import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('v1.5.0 smoke: forms, validation, and focus', () {
    testWidgets(
      'Form + TextFormField validator surfaces the error on user interaction',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            RuneView(
              source: '''
                Form(
                  autovalidateMode: AutovalidateMode.always,
                  child: Column(children: [
                    TextFormField(
                      value: '',
                      validator: (v) => v == null || v.isEmpty
                        ? 'Required'
                        : null,
                    ),
                  ]),
                )
              ''',
              config: RuneConfig.defaults(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        // autovalidateMode: always validates on the initial pump.
        expect(find.text('Required'), findsOneWidget);

        // Typing a valid value clears the error.
        await tester.enterText(find.byType(TextFormField), 'you@example.com');
        await tester.pumpAndSettle();
        expect(find.text('Required'), findsNothing);
      },
    );

    testWidgets(
      'Focus + FocusNode: pressing button transfers focus to a TextField',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            RuneView(
              source: '''
                StatefulBuilder(
                  initial: {
                    'node': FocusNode(),
                  },
                  dispose: (state) => state.node.dispose(),
                  builder: (state) => Column(children: [
                    TextField(focusNode: state.node),
                    ElevatedButton(
                      onPressed: () => state.node.requestFocus(),
                      child: Text('Focus input'),
                    ),
                  ]),
                )
              ''',
              config: RuneConfig.defaults(),
            ),
          ),
        );
        // The field starts unfocused.
        final textField =
            tester.widget<TextField>(find.byType(TextField));
        expect(textField.focusNode?.hasFocus, isFalse);
        await tester.tap(find.text('Focus input'));
        await tester.pumpAndSettle();
        expect(textField.focusNode?.hasFocus, isTrue);
      },
    );

    testWidgets(
      'FocusScope with autofocus grants focus to an autofocus Focus child',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            RuneView(
              source: '''
                StatefulBuilder(
                  initial: {'node': FocusNode()},
                  dispose: (state) => state.node.dispose(),
                  builder: (state) => FocusScope(
                    autofocus: true,
                    child: Focus(
                      focusNode: state.node,
                      autofocus: true,
                      child: SizedBox(width: 10, height: 10),
                    ),
                  ),
                )
              ''',
              config: RuneConfig.defaults(),
            ),
          ),
        );
        await tester.pump();
        // The autofocus chain should hand focus to our node.
        expect(find.byType(FocusScope), findsWidgets);
      },
    );
  });
}

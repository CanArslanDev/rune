import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('Form inputs smoke — two-way binding end-to-end', () {
    testWidgets(
      'TextField two-way binding cycle — type, host updates, re-render',
      (tester) async {
        var username = 'initial';
        Widget buildView() => _wrap(
              RuneView(
                source:
                    "TextField(value: username, onChanged: 'usernameChanged')",
                config: RuneConfig.defaults(),
                data: {'username': username},
                onEvent: (name, [args]) {
                  if (name == 'usernameChanged' && args != null) {
                    username = args[0]! as String;
                  }
                },
              ),
            );

        await tester.pumpWidget(buildView());
        expect(find.text('initial'), findsOneWidget);

        // User types: each keystroke dispatches, the host captures the
        // final state, the controller shows it.
        await tester.enterText(find.byType(TextField), 'updated');
        await tester.pump();
        expect(username, 'updated');
        expect(find.text('updated'), findsOneWidget);

        // Simulate a host rebuild after its setState. The new RuneView
        // carries the updated `username` in data; the persistent
        // controller inside `_RuneTextField` syncs without resetting
        // the cursor mid-keystroke.
        await tester.pumpWidget(buildView());
        expect(find.text('updated'), findsOneWidget);
      },
    );

    testWidgets(
      'Column of TextField + Switch + Checkbox wires up together',
      (tester) async {
        var name = 'Ali';
        var darkMode = false;
        var agreed = false;
        Widget buildView() => _wrap(
              RuneView(
                source: '''
                  Column(
                    children: [
                      TextField(value: name, onChanged: 'nameChanged'),
                      Switch(value: darkMode, onChanged: 'darkModeChanged'),
                      Checkbox(value: agreed, onChanged: 'agreedChanged'),
                    ],
                  )
                ''',
                config: RuneConfig.defaults(),
                data: {
                  'name': name,
                  'darkMode': darkMode,
                  'agreed': agreed,
                },
                onEvent: (evt, [args]) {
                  if (args == null) return;
                  switch (evt) {
                    case 'nameChanged':
                      name = args[0]! as String;
                    case 'darkModeChanged':
                      darkMode = args[0]! as bool;
                    case 'agreedChanged':
                      agreed = args[0]! as bool;
                  }
                },
              ),
            );

        await tester.pumpWidget(buildView());

        expect(find.byType(TextField), findsOneWidget);
        expect(find.byType(Switch), findsOneWidget);
        expect(find.byType(Checkbox), findsOneWidget);

        // Type into the text field.
        await tester.enterText(find.byType(TextField), 'Veli');
        await tester.pump();
        expect(name, 'Veli');

        // Flip the switch.
        await tester.tap(find.byType(Switch));
        await tester.pump();
        expect(darkMode, isTrue);

        // Toggle the checkbox.
        await tester.tap(find.byType(Checkbox));
        await tester.pump();
        expect(agreed, isTrue);
      },
    );

    testWidgets(
      'Conditional if-element composes with a form input',
      (tester) async {
        var showAdvanced = true;
        var apiKey = '';
        Widget buildView() => _wrap(
              RuneView(
                source: '''
                  Column(
                    children: [
                      Text('Settings'),
                      if (showAdvanced)
                        TextField(
                          value: apiKey,
                          onChanged: 'apiKeyChanged',
                          labelText: 'API Key',
                        ),
                    ],
                  )
                ''',
                config: RuneConfig.defaults(),
                data: {
                  'showAdvanced': showAdvanced,
                  'apiKey': apiKey,
                },
                onEvent: (evt, [args]) {
                  if (evt == 'apiKeyChanged' && args != null) {
                    apiKey = args[0]! as String;
                  }
                },
              ),
            );

        await tester.pumpWidget(buildView());
        expect(find.byType(TextField), findsOneWidget);
        await tester.enterText(find.byType(TextField), 'secret');
        await tester.pump();
        expect(apiKey, 'secret');

        // Hide the advanced section; the TextField is gone entirely.
        showAdvanced = false;
        await tester.pumpWidget(buildView());
        expect(find.byType(TextField), findsNothing);
      },
    );
  });
}

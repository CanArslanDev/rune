import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('Phase F smoke: named components via RuneCompose + RuneComponent', () {
    testWidgets('define once and use once: Greeting(who: "world")', (
      tester,
    ) async {
      const source = r'''
        RuneCompose(
          components: [
            RuneComponent(
              name: 'Greeting',
              params: ['who'],
              body: (who) => Text('Hello, ${who}!'),
            ),
          ],
          root: Greeting(who: 'world'),
        )
      ''';
      await tester.pumpWidget(
        _wrap(RuneView(source: source, config: RuneConfig.defaults())),
      );
      expect(find.text('Hello, world!'), findsOneWidget);
    });

    testWidgets(
      'define once and use multiple times with different args',
      (tester) async {
        const source = r'''
          RuneCompose(
            components: [
              RuneComponent(
                name: 'Label',
                params: ['text'],
                body: (text) => Text('> ${text}'),
              ),
            ],
            root: Column(children: [
              Label(text: 'alpha'),
              Label(text: 'beta'),
              Label(text: 'gamma'),
            ]),
          )
        ''';
        await tester.pumpWidget(
          _wrap(RuneView(source: source, config: RuneConfig.defaults())),
        );
        expect(find.text('> alpha'), findsOneWidget);
        expect(find.text('> beta'), findsOneWidget);
        expect(find.text('> gamma'), findsOneWidget);
      },
    );

    testWidgets('multiple components composed together', (tester) async {
      const source = r'''
        RuneCompose(
          components: [
            RuneComponent(
              name: 'Info',
              params: ['message'],
              body: (message) => Text('INFO: ${message}'),
            ),
            RuneComponent(
              name: 'Wrapper',
              params: ['title', 'body'],
              body: (title, body) => Column(children: [
                Text(title),
                body,
              ]),
            ),
          ],
          root: Wrapper(title: 'Hello', body: Info(message: 'World')),
        )
      ''';
      await tester.pumpWidget(
        _wrap(RuneView(source: source, config: RuneConfig.defaults())),
      );
      expect(find.text('Hello'), findsOneWidget);
      expect(find.text('INFO: World'), findsOneWidget);
    });
  });
}

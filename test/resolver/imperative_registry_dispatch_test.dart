import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('ImperativeRegistry dispatch through RuneView', () {
    testWidgets('bare imperative registered in the config runs on source call',
        (tester) async {
      final calls = <String>[];
      final config = RuneConfig.defaults();
      config.imperatives.registerBare('logSomething', (args, ctx) {
        calls.add(args.named['message']! as String);
        return null;
      });

      await tester.pumpWidget(
        _wrap(
          RuneView(
            source: '''
              ElevatedButton(
                onPressed: () => logSomething(message: 'hello'),
                child: Text('go'),
              )
            ''',
            config: config,
          ),
        ),
      );

      expect(calls, isEmpty);
      await tester.tap(find.text('go'));
      await tester.pump();
      expect(calls, ['hello']);
    });

    testWidgets(
        'prefixed imperative (Router.go) runs on source call',
        (tester) async {
      final calls = <String>[];
      final config = RuneConfig.defaults();
      config.imperatives.registerPrefixed('Router', 'go', (args, ctx) {
        calls.add(args.positionalAt<String>(0)!);
        return null;
      });

      await tester.pumpWidget(
        _wrap(
          RuneView(
            source: '''
              ElevatedButton(
                onPressed: () => Router.go('/settings'),
                child: Text('go'),
              )
            ''',
            config: config,
          ),
        ),
      );

      await tester.tap(find.text('go'));
      await tester.pump();
      expect(calls, ['/settings']);
    });

    testWidgets('registered bare imperative shadows a built-in bridge',
        (tester) async {
      // Shadow the v1.3 showSnackBar built-in with a counting stub to
      // prove registry-first precedence.
      final shadowCalls = <int>[];
      final config = RuneConfig.defaults();
      config.imperatives.registerBare('showSnackBar', (args, ctx) {
        shadowCalls.add(shadowCalls.length + 1);
        return null;
      });

      await tester.pumpWidget(
        _wrap(
          RuneView(
            source: '''
              ElevatedButton(
                onPressed: () => showSnackBar(SnackBar(content: Text('ignored'))),
                child: Text('go'),
              )
            ''',
            config: config,
          ),
        ),
      );

      await tester.tap(find.text('go'));
      await tester.pump();
      expect(shadowCalls, [1]);
    });

    testWidgets(
        'Navigator.* built-ins still win when no prefixed registration exists',
        (tester) async {
      // Baseline: a Navigator.push call with no Router.* registration
      // should still hit the built-in Navigator bridge.
      final config = RuneConfig.defaults();
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/',
          routes: {
            '/': (_) => Scaffold(
                  body: RuneView(
                    config: config,
                    source: '''
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed('/b'),
                        child: Text('go'),
                      )
                    ''',
                  ),
                ),
            '/b': (_) => const Scaffold(body: Text('page-b')),
          },
        ),
      );

      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      expect(find.text('page-b'), findsOneWidget);
    });
  });
}

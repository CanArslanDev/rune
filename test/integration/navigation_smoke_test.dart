import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';

void main() {
  group('v1.6.0 smoke: navigation and routing', () {
    testWidgets(
      'Navigator.push + Navigator.pop round-trip between two pages',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RuneView(
                source: '''
                  Column(
                    children: [
                      Text('Home'),
                      ElevatedButton(
                        onPressed: () => Navigator.push(
                          MaterialPageRoute(
                            builder: (ctx) => Scaffold(
                              appBar: AppBar(title: Text('Detail')),
                              body: ElevatedButton(
                                onPressed: () => Navigator.pop(),
                                child: Text('Back'),
                              ),
                            ),
                          ),
                        ),
                        child: Text('Open'),
                      ),
                    ],
                  )
                ''',
                config: RuneConfig.defaults(),
              ),
            ),
          ),
        );
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Detail'), findsNothing);

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(find.text('Detail'), findsOneWidget);
        expect(find.text('Back'), findsOneWidget);

        await tester.tap(find.text('Back'));
        await tester.pumpAndSettle();
        expect(find.text('Detail'), findsNothing);
        expect(find.text('Home'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Navigator.pushNamed routes through MaterialApp.routes',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RuneView(
                source: '''
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed('/profile'),
                    child: Text('Profile'),
                  )
                ''',
                config: RuneConfig.defaults(),
              ),
            ),
            routes: {
              '/profile': (ctx) => const Scaffold(
                    body: Center(child: Text('Profile page')),
                  ),
            },
          ),
        );
        expect(find.text('Profile page'), findsNothing);
        await tester.tap(find.text('Profile'));
        await tester.pumpAndSettle();
        expect(find.text('Profile page'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}

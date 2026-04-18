import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('Phase 3b integration — deep paths + index + for-elements', () {
    testWidgets('deep dot-path: Text(user.profile.name)', (tester) async {
      await tester.pumpWidget(
        _wrap(
          RuneView(
            source: 'Text(user.profile.name)',
            config: RuneConfig.defaults(),
            data: const {
              'user': {
                'profile': {'name': 'Ali'},
              },
            },
          ),
        ),
      );
      expect(find.text('Ali'), findsOneWidget);
    });

    testWidgets('index access: Text(items[1])', (tester) async {
      await tester.pumpWidget(
        _wrap(
          RuneView(
            source: 'Text(items[1])',
            config: RuneConfig.defaults(),
            data: const {
              'items': ['first', 'second', 'third'],
            },
          ),
        ),
      );
      expect(find.text('second'), findsOneWidget);
    });

    testWidgets('index + dot-path: Text(items[0].title)', (tester) async {
      await tester.pumpWidget(
        _wrap(
          RuneView(
            source: 'Text(items[0].title)',
            config: RuneConfig.defaults(),
            data: const {
              'items': [
                {'title': 'first-title'},
                {'title': 'second-title'},
              ],
            },
          ),
        ),
      );
      expect(find.text('first-title'), findsOneWidget);
    });

    testWidgets('for-element: Column of Texts from data list',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          RuneView(
            source: '''
              Column(children: [
                for (final label in labels) Text(label),
              ])
            ''',
            config: RuneConfig.defaults(),
            data: const {
              'labels': ['alpha', 'beta', 'gamma'],
            },
          ),
        ),
      );
      expect(find.text('alpha'), findsOneWidget);
      expect(find.text('beta'), findsOneWidget);
      expect(find.text('gamma'), findsOneWidget);
    });

    testWidgets(
      'for-element with item.title deep access inside builder',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            RuneView(
              source: '''
                ListView(
                  shrinkWrap: true,
                  children: [
                    for (final item in items)
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(item.title),
                        ),
                      ),
                  ],
                )
              ''',
              config: RuneConfig.defaults(),
              data: const {
                'items': [
                  {'title': 'Home'},
                  {'title': 'Settings'},
                  {'title': 'Profile'},
                ],
              },
            ),
          ),
        );
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Settings'), findsOneWidget);
        expect(find.text('Profile'), findsOneWidget);
        expect(find.byType(Card), findsNWidgets(3));
      },
    );

    testWidgets('for-element with static elements around it',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          RuneView(
            source: '''
              Column(children: [
                Text('header'),
                for (final label in labels) Text(label),
                Text('footer'),
              ])
            ''',
            config: RuneConfig.defaults(),
            data: const {
              'labels': ['one', 'two'],
            },
          ),
        ),
      );
      final column = tester.widget<Column>(find.byType(Column));
      expect(column.children.length, 4);
      expect(find.text('header'), findsOneWidget);
      expect(find.text('one'), findsOneWidget);
      expect(find.text('two'), findsOneWidget);
      expect(find.text('footer'), findsOneWidget);
    });
  });
}

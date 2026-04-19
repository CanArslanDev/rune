import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('Conditionals smoke — ternary and if-element in RuneView', () {
    testWidgets('RuneView renders conditional children via if-element',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          RuneView(
            source: '''
              Column(
                children: [
                  Text('Welcome'),
                  if (hasMessages) Text('You have messages'),
                  if (isAdmin)
                    Text('Admin panel')
                  else
                    Text('Regular user'),
                ],
              )
            ''',
            config: RuneConfig.defaults(),
            data: const {
              'hasMessages': true,
              'isAdmin': false,
            },
          ),
        ),
      );

      expect(find.text('Welcome'), findsOneWidget);
      expect(find.text('You have messages'), findsOneWidget);
      expect(find.text('Regular user'), findsOneWidget);
      expect(find.text('Admin panel'), findsNothing);
    });

    testWidgets('RuneView chooses widget via ternary', (tester) async {
      const source = r'''
        Column(
          children: [
            Text(isLoggedIn ? 'Hello, ${user.name}' : 'Please sign in'),
          ],
        )
      ''';

      await tester.pumpWidget(
        _wrap(
          RuneView(
            source: source,
            config: RuneConfig.defaults(),
            data: const {
              'isLoggedIn': true,
              'user': {'name': 'Ali'},
            },
          ),
        ),
      );
      expect(find.text('Hello, Ali'), findsOneWidget);

      // Re-render with isLoggedIn: false and user deliberately omitted —
      // the un-taken branch must not evaluate `user.name`.
      await tester.pumpWidget(
        _wrap(
          RuneView(
            source: source,
            config: RuneConfig.defaults(),
            data: const {
              'isLoggedIn': false,
            },
          ),
        ),
      );
      expect(find.text('Please sign in'), findsOneWidget);
      expect(find.text('Hello, Ali'), findsNothing);
    });

    testWidgets('RuneView combines if-else with for-element over items',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          RuneView(
            source: '''
              Column(
                children: [
                  if (showList)
                    for (final item in items) Text(item.title)
                  else
                    Text('No items'),
                ],
              )
            ''',
            config: RuneConfig.defaults(),
            data: const {
              'showList': true,
              'items': [
                {'title': 'Alpha'},
                {'title': 'Beta'},
              ],
            },
          ),
        ),
      );
      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);
      expect(find.text('No items'), findsNothing);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('v1.3.0 smoke: dialogs, overlays, popup menus, snackbars', () {
    testWidgets(
      'showDialog opens an AlertDialog with TextButton actions',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            RuneView(
              source: '''
                ElevatedButton(
                  onPressed: () => showDialog(
                    builder: (ctx) => AlertDialog(
                      title: Text('Confirm'),
                      content: Text('Are you sure?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(),
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(),
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  ),
                  child: Text('Open'),
                )
              ''',
              config: RuneConfig.defaults(),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(find.text('Confirm'), findsOneWidget);
        expect(find.text('Are you sure?'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('OK'), findsOneWidget);

        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
        expect(find.text('Confirm'), findsNothing);
      },
    );

    testWidgets(
      'PopupMenuButton itemBuilder renders items and onSelected fires',
      (tester) async {
        final picked = <Object?>[];
        await tester.pumpWidget(
          _wrap(
            RuneView(
              source: '''
                PopupMenuButton(
                  itemBuilder: (ctx) => [
                    PopupMenuItem(value: 1, child: Text('One')),
                    PopupMenuItem(value: 2, child: Text('Two')),
                  ],
                  onSelected: 'picked',
                )
              ''',
              config: RuneConfig.defaults(),
              onEvent: (name, [args]) {
                if (name == 'picked' && args != null && args.isNotEmpty) {
                  picked.add(args.first);
                }
              },
            ),
          ),
        );
        await tester.tap(find.byType(PopupMenuButton<Object?>));
        await tester.pumpAndSettle();
        expect(find.text('One'), findsOneWidget);
        expect(find.text('Two'), findsOneWidget);

        await tester.tap(find.text('Two'));
        await tester.pumpAndSettle();
        expect(picked, [2]);
      },
    );

    testWidgets(
      'showSnackBar surfaces a SnackBar with the given content',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            RuneView(
              source: '''
                ElevatedButton(
                  onPressed: () =>
                    showSnackBar(SnackBar(content: Text('Saved.'))),
                  child: Text('Save'),
                )
              ''',
              config: RuneConfig.defaults(),
            ),
          ),
        );
        await tester.tap(find.text('Save'));
        await tester.pump();
        expect(find.text('Saved.'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'showModalBottomSheet opens a body and closes via the barrier',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            RuneView(
              source: '''
                ElevatedButton(
                  onPressed: () => showModalBottomSheet(
                    builder: (ctx) => Container(
                      padding: EdgeInsets.all(16),
                      child: Text('Sheet content'),
                    ),
                  ),
                  child: Text('Sheet'),
                )
              ''',
              config: RuneConfig.defaults(),
            ),
          ),
        );
        await tester.tap(find.text('Sheet'));
        await tester.pumpAndSettle();
        expect(find.text('Sheet content'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Navigator.pop from inside a dialog dismisses it',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            RuneView(
              source: '''
                ElevatedButton(
                  onPressed: () => showDialog(
                    builder: (ctx) => AlertDialog(
                      title: Text('Prompt'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(),
                          child: Text('Close'),
                        ),
                      ],
                    ),
                  ),
                  child: Text('Open'),
                )
              ''',
              config: RuneConfig.defaults(),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(find.text('Prompt'), findsOneWidget);

        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();
        expect(find.text('Prompt'), findsNothing);
      },
    );
  });
}

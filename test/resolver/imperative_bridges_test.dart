import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('v1.3.0 imperative bridges via RuneView', () {
    testWidgets(
      'showDialog opens an AlertDialog when invoked from onPressed',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            RuneView(
              source: '''
                ElevatedButton(
                  onPressed: () => showDialog(
                    builder: (ctx) => AlertDialog(
                      title: Text('Confirm'),
                      content: Text('Body'),
                    ),
                  ),
                  child: Text('Open'),
                )
              ''',
              config: RuneConfig.defaults(),
            ),
          ),
        );
        expect(find.text('Open'), findsOneWidget);
        expect(find.text('Confirm'), findsNothing);

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(find.text('Confirm'), findsOneWidget);
        expect(find.text('Body'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'showDialog without a builder raises a ResolveException surfaced as '
      'an error widget',
      (tester) async {
        Object? caught;
        await tester.pumpWidget(
          _wrap(
            RuneView(
              source: '''
                ElevatedButton(
                  onPressed: () => showDialog(),
                  child: Text('Open'),
                )
              ''',
              config: RuneConfig.defaults(),
              onError: (e, _) => caught = e,
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pump();
        // The builder closure is missing so the bridge surfaces an
        // ArgumentException; tap-triggered exceptions bubble through
        // `FlutterError.onError` rather than RuneView.onError, so we
        // fish them out via `tester.takeException()`.
        final err = tester.takeException();
        expect(
          err ?? caught,
          isA<RuneException>(),
        );
      },
    );

    testWidgets(
      'showModalBottomSheet opens a non-null body when invoked',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            RuneView(
              source: '''
                ElevatedButton(
                  onPressed: () => showModalBottomSheet(
                    builder: (ctx) => SizedBox(
                      height: 120,
                      child: Center(child: Text('SheetBody')),
                    ),
                  ),
                  child: Text('Sheet'),
                )
              ''',
              config: RuneConfig.defaults(),
            ),
          ),
        );
        expect(find.text('SheetBody'), findsNothing);
        await tester.tap(find.text('Sheet'));
        await tester.pumpAndSettle();
        expect(find.text('SheetBody'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'showSnackBar with a bare SnackBar positional surfaces a SnackBar',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            RuneView(
              source: '''
                ElevatedButton(
                  onPressed: () =>
                    showSnackBar(SnackBar(content: Text('hello-snack'))),
                  child: Text('Ring'),
                )
              ''',
              config: RuneConfig.defaults(),
            ),
          ),
        );
        await tester.tap(find.text('Ring'));
        await tester.pump();
        expect(find.text('hello-snack'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'showSnackBar without an argument raises an ArgumentException',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            RuneView(
              source: '''
                ElevatedButton(
                  onPressed: () => showSnackBar(),
                  child: Text('Ring'),
                )
              ''',
              config: RuneConfig.defaults(),
            ),
          ),
        );
        await tester.tap(find.text('Ring'));
        await tester.pump();
        expect(tester.takeException(), isA<RuneException>());
      },
    );

    testWidgets(
      'Navigator.pop closes a pushed dialog',
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
        expect(tester.takeException(), isNull);
      },
    );
  });
}

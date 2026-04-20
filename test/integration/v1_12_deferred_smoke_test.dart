import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('v1.12.0 deferred-item closeout smokes', () {
    testWidgets('ListenableBuilder subscribes to the Listenable',
        (tester) async {
      final notifier = ValueNotifier<int>(0);
      addTearDown(notifier.dispose);
      // ValueNotifier.value is not on the built-in property whitelist;
      // the smoke verifies the subscription wiring rather than runtime
      // value reads. Rebuild must not raise on notifyListeners().
      await tester.pumpWidget(
        _wrap(
          RuneView(
            source: '''
              ListenableBuilder(
                listenable: counter,
                builder: (ctx, child) => Text('tick'),
              )
            ''',
            config: RuneConfig.defaults(),
            data: {'counter': notifier},
          ),
        ),
      );
      expect(find.text('tick'), findsOneWidget);
      notifier.value = 3;
      await tester.pump();
      expect(find.text('tick'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('PageRouteBuilder pushes a custom-transition route',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          RuneView(
            source: '''
              ElevatedButton(
                onPressed: () => Navigator.push(
                  PageRouteBuilder(
                    pageBuilder: (ctx, a, s) => Scaffold(body: Text('Detail')),
                    transitionDuration: Duration(milliseconds: 20),
                    reverseTransitionDuration: Duration(milliseconds: 20),
                  ),
                ),
                child: Text('Open'),
              )
            ''',
            config: RuneConfig.defaults(),
          ),
        ),
      );
      expect(find.text('Detail'), findsNothing);
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Detail'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Navigator.popUntil pops back to the first route',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).push<void>(
                    MaterialPageRoute<void>(
                      builder: (inner) => Scaffold(
                        body: RuneView(
                          source: '''
                            ElevatedButton(
                              onPressed: () => Navigator.popUntil((r) => r.isFirst),
                              child: Text('PopRoot'),
                            )
                          ''',
                          config: RuneConfig.defaults(),
                        ),
                      ),
                    ),
                  );
                },
                child: const Text('Push'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Push'));
      await tester.pumpAndSettle();
      expect(find.text('PopRoot'), findsOneWidget);
      await tester.tap(find.text('PopRoot'));
      await tester.pumpAndSettle();
      // Back on the root page after popUntil((r) => r.isFirst) ran.
      expect(find.text('Push'), findsOneWidget);
      expect(find.text('PopRoot'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'Navigator.popUntil with a non-bool predicate raises a RuneException',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            RuneView(
              source: '''
                ElevatedButton(
                  onPressed: () => Navigator.popUntil((r) => 'nope'),
                  child: Text('Go'),
                )
              ''',
              config: RuneConfig.defaults(),
            ),
          ),
        );
        await tester.tap(find.text('Go'));
        await tester.pump();
        expect(tester.takeException(), isA<RuneException>());
      },
    );

    testWidgets('PaginatedDataTable renders from a RuneDataTableSource',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          SingleChildScrollView(
            child: RuneView(
              source: '''
                PaginatedDataTable(
                  columns: [
                    DataColumn(label: Text('Name')),
                  ],
                  rowsPerPage: 2,
                  source: RuneDataTableSource(
                    rows: [
                      DataRow(cells: [DataCell(Text('A'))]),
                      DataRow(cells: [DataCell(Text('B'))]),
                      DataRow(cells: [DataCell(Text('C'))]),
                    ],
                  ),
                )
              ''',
              config: RuneConfig.defaults(),
            ),
          ),
        ),
      );
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      // Row C is on page 2.
      expect(find.text('C'), findsNothing);
    });

    testWidgets('showMenu opens a menu at a RelativeRect anchor',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          RuneView(
            source: '''
              ElevatedButton(
                onPressed: () => showMenu(
                  position: RelativeRect.fromLTRB(10, 10, 10, 10),
                  items: [
                    PopupMenuItem(value: 'one', child: Text('One')),
                    PopupMenuItem(value: 'two', child: Text('Two')),
                  ],
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
      expect(find.text('One'), findsOneWidget);
      expect(find.text('Two'), findsOneWidget);
    });

    testWidgets('FilledButton.tonal builds and taps', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(
        _wrap(
          RuneView(
            source: '''
              FilledButton.tonal(
                onPressed: 'tap',
                child: Text('Tonal'),
              )
            ''',
            config: RuneConfig.defaults(),
            onEvent: (name, [args]) {
              if (name == 'tap') tapped++;
            },
          ),
        ),
      );
      expect(find.text('Tonal'), findsOneWidget);
      await tester.tap(find.text('Tonal'));
      await tester.pump();
      expect(tapped, 1);
    });

    testWidgets('SnackBarAction plumbs into a SnackBar', (tester) async {
      var undone = 0;
      await tester.pumpWidget(
        _wrap(
          RuneView(
            source: '''
              ElevatedButton(
                onPressed: () => showSnackBar(
                  SnackBar(
                    content: Text('Deleted'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: 'undo',
                    ),
                  ),
                ),
                child: Text('Delete'),
              )
            ''',
            config: RuneConfig.defaults(),
            onEvent: (name, [args]) {
              if (name == 'undo') undone++;
            },
          ),
        ),
      );
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(find.text('Undo'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await tester.pump();
      expect(undone, 1);
    });
  });
}

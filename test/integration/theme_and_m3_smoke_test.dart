import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';

// Wraps [child] in a MaterialApp + Scaffold so Material widgets inside
// [child] have the ancestors they require (Theme, MediaQuery, Navigator).
Widget _wrap(Widget child, {ThemeData? theme}) => MaterialApp(
      theme: theme,
      home: Scaffold(body: child),
    );

void main() {
  group('v1.4.0 smoke: theme access + Material 3 widgets', () {
    testWidgets(
      'FilledButton and OutlinedButton render in the tree',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            RuneView(
              source: '''
                Column(children: [
                  FilledButton(
                    onPressed: 'submit',
                    child: Text('Filled'),
                  ),
                  OutlinedButton(
                    onPressed: 'cancel',
                    child: Text('Outlined'),
                  ),
                ])
              ''',
              config: RuneConfig.defaults(),
            ),
          ),
        );
        expect(find.byType(FilledButton), findsOneWidget);
        expect(find.byType(OutlinedButton), findsOneWidget);
        expect(find.text('Filled'), findsOneWidget);
        expect(find.text('Outlined'), findsOneWidget);
      },
    );

    testWidgets(
      'SegmentedButton renders with segments, onSelectionChanged fires',
      (tester) async {
        Set<Object?>? last;
        await tester.pumpWidget(
          _wrap(
            RuneView(
              source: '''
                SegmentedButton(
                  segments: [
                    ButtonSegment(value: 'a', label: Text('A')),
                    ButtonSegment(value: 'b', label: Text('B')),
                  ],
                  selected: {'a'},
                  onSelectionChanged: 'segPicked',
                )
              ''',
              config: RuneConfig.defaults(),
              onEvent: (name, [args]) {
                if (name == 'segPicked' && args != null && args.isNotEmpty) {
                  last = args.first as Set<Object?>?;
                }
              },
            ),
          ),
        );
        expect(find.byType(SegmentedButton<Object?>), findsOneWidget);
        // Tap the "B" segment - verify the event fires with the new
        // selection set.
        await tester.tap(find.text('B'));
        await tester.pumpAndSettle();
        expect(last, contains('b'));
      },
    );

    testWidgets(
      'Theme.of(ctx) via LayoutBuilder drives theme-aware Container color',
      (tester) async {
        final seeded = ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        );
        await tester.pumpWidget(
          _wrap(
            RuneView(
              source: '''
                LayoutBuilder(
                  builder: (ctx, constraints) => Container(
                    width: 120,
                    height: 120,
                    color: Theme.of(ctx).colorScheme.primary,
                  ),
                )
              ''',
              config: RuneConfig.defaults(),
            ),
            theme: seeded,
          ),
        );
        final container = tester.widget<Container>(find.byType(Container));
        expect(container.color, seeded.colorScheme.primary);
      },
    );

    testWidgets(
      'SearchBar renders and forwards hintText',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            RuneView(
              source: '''
                SearchBar(
                  hintText: 'Search docs',
                  leading: Icon(Icons.search),
                )
              ''',
              config: RuneConfig.defaults(),
            ),
          ),
        );
        expect(find.byType(SearchBar), findsOneWidget);
        expect(find.text('Search docs'), findsOneWidget);
      },
    );

    testWidgets(
      'showDatePicker launches a date picker dialog',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            RuneView(
              source: '''
                FilledButton(
                  onPressed: () => showDatePicker(
                    initialDate: DateTime(2026, 4, 19),
                    firstDate: DateTime(2020, 1, 1),
                    lastDate: DateTime(2030, 12, 31),
                  ),
                  child: Text('Pick'),
                )
              ''',
              config: RuneConfig.defaults(),
            ),
          ),
        );
        expect(find.byType(DatePickerDialog), findsNothing);
        await tester.tap(find.text('Pick'));
        await tester.pumpAndSettle();
        expect(find.byType(DatePickerDialog), findsOneWidget);
      },
    );
  });
}

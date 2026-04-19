import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/list_tile_builder.dart';

import '../_helpers/test_context.dart';

Widget _harness(Widget built) => MaterialApp(home: Scaffold(body: built));

void main() {
  group('ListTileBuilder', () {
    const b = ListTileBuilder();

    test('typeName is "ListTile"', () {
      expect(b.typeName, 'ListTile');
    });

    testWidgets('title-only tile renders its title text', (tester) async {
      final built = b.build(
        const ResolvedArguments(named: {'title': Text('Hello')}),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      expect(find.byType(ListTile), findsOneWidget);
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('title, subtitle, leading, trailing all plumb through',
        (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {
            'title': Text('T'),
            'subtitle': Text('S'),
            'leading': Text('L'),
            'trailing': Text('R'),
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      expect(find.byType(ListTile), findsOneWidget);
      expect(find.text('T'), findsOneWidget);
      expect(find.text('S'), findsOneWidget);
      expect(find.text('L'), findsOneWidget);
      expect(find.text('R'), findsOneWidget);
    });

    testWidgets('onTap event name dispatches with empty args when tapped',
        (tester) async {
      final events = RuneEventDispatcher();
      final names = <String>[];
      final argLists = <List<Object?>>[];
      events.setCatchAllHandler((name, args) {
        names.add(name);
        argLists.add(args);
      });
      final built = b.build(
        const ResolvedArguments(
          named: {
            'title': Text('Tap me'),
            'onTap': 'row-tapped',
          },
        ),
        testContext(events: events),
      );
      await tester.pumpWidget(_harness(built));
      await tester.tap(find.byType(ListTile));
      await tester.pump();
      expect(names, ['row-tapped']);
      expect(argLists, [<Object?>[]]);
    });

    testWidgets('missing onTap leaves ListTile.onTap null', (tester) async {
      final built = b.build(
        const ResolvedArguments(named: {'title': Text('No tap')}),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      final tile = tester.widget<ListTile>(find.byType(ListTile));
      expect(tile.onTap, isNull);
    });

    testWidgets('dense, enabled, selected boolean flags plumb through',
        (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {
            'title': Text('Flagged'),
            'dense': true,
            'enabled': false,
            'selected': true,
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      final tile = tester.widget<ListTile>(find.byType(ListTile));
      expect(tile.dense, isTrue);
      expect(tile.enabled, isFalse);
      expect(tile.selected, isTrue);
    });

    testWidgets('enabled defaults to true, selected defaults to false',
        (tester) async {
      final built = b.build(
        const ResolvedArguments(named: {'title': Text('Default flags')}),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      final tile = tester.widget<ListTile>(find.byType(ListTile));
      expect(tile.enabled, isTrue);
      expect(tile.selected, isFalse);
    });
  });
}

// ignore_for_file: deprecated_member_use
//
// Rationale: reads SwitchListTile.activeColor to verify plumbing; the
// builder intentionally keeps the pre-3.31 slot. See the builder's
// own file header for the long-form discussion.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/switch_list_tile_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

Widget _harness(Widget built) => MaterialApp(home: Scaffold(body: built));

void main() {
  group('SwitchListTileBuilder', () {
    const b = SwitchListTileBuilder();

    test('typeName is "SwitchListTile"', () {
      expect(b.typeName, 'SwitchListTile');
    });

    testWidgets('value: true with title plumbs through', (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {'value': true, 'title': Text('Notify')},
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      final tile = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
      expect(tile.value, isTrue);
      expect(find.text('Notify'), findsOneWidget);
    });

    test('missing value throws ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });

    testWidgets('onChanged tap dispatches new bool', (tester) async {
      final events = RuneEventDispatcher();
      final captured = <List<Object?>>[];
      events.setCatchAllHandler((name, args) {
        if (name == 'toggled') captured.add(args);
      });
      final built = b.build(
        const ResolvedArguments(
          named: {
            'value': false,
            'title': Text('Enable'),
            'onChanged': 'toggled',
          },
        ),
        testContext(events: events),
      );
      await tester.pumpWidget(_harness(built));
      await tester.tap(find.byType(SwitchListTile));
      await tester.pump();
      expect(captured, [
        [true],
      ]);
    });

    testWidgets('optional subtitle / secondary / controlAffinity plumb',
        (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {
            'value': true,
            'title': Text('Title'),
            'subtitle': Text('Sub'),
            'secondary': Icon(Icons.notifications),
            'controlAffinity': ListTileControlAffinity.leading,
            'dense': true,
            'activeColor': Color(0xFFAABBCC),
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      final tile = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
      expect(tile.subtitle, isNotNull);
      expect(tile.secondary, isNotNull);
      expect(tile.controlAffinity, ListTileControlAffinity.leading);
      expect(tile.dense, isTrue);
      expect(tile.activeColor, const Color(0xFFAABBCC));
    });
  });
}

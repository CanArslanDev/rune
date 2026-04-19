// ignore_for_file: deprecated_member_use
//
// Rationale: RadioListTileBuilder intentionally keeps Flutter's
// pre-3.41 direct groupValue / onChanged contract rather than a
// RadioGroup ancestor. Tests read the deprecated slots to verify
// plumbing. See RadioBuilder's class dartdoc for the long-form
// discussion.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/radio_list_tile_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

Widget _harness(Widget built) => MaterialApp(home: Scaffold(body: built));

void main() {
  group('RadioListTileBuilder', () {
    const b = RadioListTileBuilder();

    test('typeName is "RadioListTile"', () {
      expect(b.typeName, 'RadioListTile');
    });

    testWidgets('value == groupValue renders selected', (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {
            'value': 1,
            'groupValue': 1,
            'title': Text('One'),
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      final tile = tester.widget<RadioListTile<Object?>>(
        find.byType(RadioListTile<Object?>),
      );
      expect(tile.value, 1);
      expect(tile.groupValue, 1);
    });

    testWidgets('value != groupValue renders unselected', (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {
            'value': 2,
            'groupValue': 1,
            'title': Text('Two'),
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      final tile = tester.widget<RadioListTile<Object?>>(
        find.byType(RadioListTile<Object?>),
      );
      expect(tile.value, 2);
      expect(tile.groupValue, 1);
    });

    test('missing value throws ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('explicit value: null does NOT throw', () {
      final w = b.build(
        const ResolvedArguments(named: {'value': null}),
        testContext(),
      ) as RadioListTile<Object?>;
      expect(w.value, isNull);
    });

    testWidgets('tap dispatches this tile own value', (tester) async {
      final events = RuneEventDispatcher();
      final captured = <List<Object?>>[];
      events.setCatchAllHandler((name, args) {
        if (name == 'picked') captured.add(args);
      });
      final built = b.build(
        const ResolvedArguments(
          named: {
            'value': 'alpha',
            'groupValue': 'beta',
            'title': Text('Alpha'),
            'onChanged': 'picked',
          },
        ),
        testContext(events: events),
      );
      await tester.pumpWidget(_harness(built));
      await tester.tap(find.byType(RadioListTile<Object?>));
      await tester.pump();
      expect(captured, [
        ['alpha'],
      ]);
    });

    testWidgets('optional subtitle / secondary / controlAffinity plumb',
        (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {
            'value': 1,
            'groupValue': 1,
            'title': Text('Title'),
            'subtitle': Text('Sub'),
            'secondary': Icon(Icons.star),
            'toggleable': true,
            'controlAffinity': ListTileControlAffinity.leading,
            'dense': true,
            'activeColor': Color(0xFF446688),
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      final tile = tester.widget<RadioListTile<Object?>>(
        find.byType(RadioListTile<Object?>),
      );
      expect(tile.subtitle, isNotNull);
      expect(tile.secondary, isNotNull);
      expect(tile.toggleable, isTrue);
      expect(tile.controlAffinity, ListTileControlAffinity.leading);
      expect(tile.dense, isTrue);
      expect(tile.activeColor, const Color(0xFF446688));
    });
  });
}

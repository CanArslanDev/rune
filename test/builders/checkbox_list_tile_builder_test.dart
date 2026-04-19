import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/checkbox_list_tile_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

Widget _harness(Widget built) => MaterialApp(home: Scaffold(body: built));

void main() {
  group('CheckboxListTileBuilder', () {
    const b = CheckboxListTileBuilder();

    test('typeName is "CheckboxListTile"', () {
      expect(b.typeName, 'CheckboxListTile');
    });

    testWidgets('value: true with title plumbs through', (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {'value': true, 'title': Text('Agree')},
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      final tile = tester.widget<CheckboxListTile>(
        find.byType(CheckboxListTile),
      );
      expect(tile.value, isTrue);
      expect(find.text('Agree'), findsOneWidget);
    });

    test('missing value throws ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('explicit value: null does NOT throw (tristate)', () {
      final w = b.build(
        const ResolvedArguments(
          named: {'value': null, 'tristate': true},
        ),
        testContext(),
      ) as CheckboxListTile;
      expect(w.value, isNull);
      expect(w.tristate, isTrue);
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
            'title': Text('Accept'),
            'onChanged': 'toggled',
          },
        ),
        testContext(events: events),
      );
      await tester.pumpWidget(_harness(built));
      await tester.tap(find.byType(CheckboxListTile));
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
            'secondary': Icon(Icons.check),
            'tristate': true,
            'controlAffinity': ListTileControlAffinity.leading,
            'dense': true,
            'activeColor': Color(0xFF112233),
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      final tile = tester.widget<CheckboxListTile>(
        find.byType(CheckboxListTile),
      );
      expect(tile.subtitle, isNotNull);
      expect(tile.secondary, isNotNull);
      expect(tile.tristate, isTrue);
      expect(tile.controlAffinity, ListTileControlAffinity.leading);
      expect(tile.dense, isTrue);
      expect(tile.activeColor, const Color(0xFF112233));
    });
  });
}

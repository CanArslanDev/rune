import 'package:flutter/material.dart' hide DropdownButtonBuilder;
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/dropdown_button_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

Widget _harness(Widget built) => MaterialApp(
      home: Scaffold(body: Center(child: built)),
    );

const _itemOne = DropdownMenuItem<Object?>(value: 1, child: Text('One'));
const _itemTwo = DropdownMenuItem<Object?>(value: 2, child: Text('Two'));
const _itemThree = DropdownMenuItem<Object?>(value: 3, child: Text('Three'));

void main() {
  group('DropdownButtonBuilder', () {
    const b = DropdownButtonBuilder();

    test('typeName is "DropdownButton"', () {
      expect(b.typeName, 'DropdownButton');
    });

    testWidgets('renders with 3 items + value: 2', (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {
            'items': <Object?>[_itemOne, _itemTwo, _itemThree],
            'value': 2,
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      expect(find.byType(DropdownButton<Object?>), findsOneWidget);
      final dd = tester.widget<DropdownButton<Object?>>(
        find.byType(DropdownButton<Object?>),
      );
      expect(dd.items!.length, 3);
      expect(dd.value, 2);
    });

    test('missing items throws ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(named: {'value': 1}),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    testWidgets('empty items: [] renders', (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {'items': <Object?>[]},
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      expect(find.byType(DropdownButton<Object?>), findsOneWidget);
      final dd = tester.widget<DropdownButton<Object?>>(
        find.byType(DropdownButton<Object?>),
      );
      expect(dd.items, isEmpty);
    });

    testWidgets('value absent with hint renders the hint', (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {
            'items': <Object?>[_itemOne, _itemTwo],
            'hint': Text('Pick one'),
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      final dd = tester.widget<DropdownButton<Object?>>(
        find.byType(DropdownButton<Object?>),
      );
      expect(dd.value, isNull);
      expect(dd.hint, isA<Text>());
    });

    test('onChanged dispatches (eventName, [newValue])', () {
      final events = RuneEventDispatcher();
      final captured = <List<Object?>>[];
      events.setCatchAllHandler((name, args) {
        if (name == 'picked') captured.add(args);
      });
      final built = b.build(
        const ResolvedArguments(
          named: {
            'items': <Object?>[_itemOne, _itemTwo],
            'value': 1,
            'onChanged': 'picked',
          },
        ),
        testContext(events: events),
      ) as DropdownButton<Object?>;
      built.onChanged!(2);
      expect(captured, [
        [2],
      ]);
    });

    testWidgets('isExpanded: true plumbs through', (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {
            'items': <Object?>[_itemOne, _itemTwo],
            'value': 1,
            'isExpanded': true,
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      final dd = tester.widget<DropdownButton<Object?>>(
        find.byType(DropdownButton<Object?>),
      );
      expect(dd.isExpanded, isTrue);
    });

    testWidgets('disabledHint + missing onChanged renders disabled',
        (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {
            'items': <Object?>[_itemOne, _itemTwo],
            'disabledHint': Text('Disabled'),
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      final dd = tester.widget<DropdownButton<Object?>>(
        find.byType(DropdownButton<Object?>),
      );
      expect(dd.onChanged, isNull);
      expect(dd.disabledHint, isA<Text>());
    });
  });
}

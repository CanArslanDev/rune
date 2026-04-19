import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/choice_chip_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('ChoiceChipBuilder', () {
    const b = ChoiceChipBuilder();

    test('typeName is "ChoiceChip"', () {
      expect(b.typeName, 'ChoiceChip');
    });

    testWidgets('required label + selected plumb through', (tester) async {
      final w = b.build(
        const ResolvedArguments(
          named: {'label': Text('Opt'), 'selected': true},
        ),
        testContext(),
      ) as ChoiceChip;

      expect(w.selected, isTrue);
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: w)),
      );
      expect(find.text('Opt'), findsOneWidget);
    });

    test('missing label throws ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(named: {'selected': false}),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('missing selected throws ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(named: {'label': Text('Opt')}),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('onSelected dispatches (name, [newBool])', () {
      final events = RuneEventDispatcher();
      final received = <List<Object?>>[];
      events.setCatchAllHandler((name, args) {
        received.add([name, args]);
      });
      final w = b.build(
        const ResolvedArguments(
          named: {
            'label': Text('Opt'),
            'selected': false,
            'onSelected': 'pick',
          },
        ),
        testContext(events: events),
      ) as ChoiceChip;

      expect(w.onSelected, isNotNull);
      w.onSelected!.call(true);
      expect(received.length, 1);
      expect(received.first[0], 'pick');
      expect(received.first[1], <Object?>[true]);
    });
  });
}

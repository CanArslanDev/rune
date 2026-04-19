import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/filter_chip_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('FilterChipBuilder', () {
    const b = FilterChipBuilder();

    test('typeName is "FilterChip"', () {
      expect(b.typeName, 'FilterChip');
    });

    testWidgets('required label + selected plumb through', (tester) async {
      final w = b.build(
        const ResolvedArguments(
          named: {'label': Text('Tag'), 'selected': false},
        ),
        testContext(),
      ) as FilterChip;

      expect(w.selected, isFalse);
      // showCheckmark defaults to true.
      expect(w.showCheckmark, isTrue);
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: w)),
      );
      expect(find.text('Tag'), findsOneWidget);
    });

    test('missing label throws ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(named: {'selected': true}),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('missing selected throws ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(named: {'label': Text('Tag')}),
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
            'label': Text('Tag'),
            'selected': true,
            'onSelected': 'toggle',
          },
        ),
        testContext(events: events),
      ) as FilterChip;

      expect(w.onSelected, isNotNull);
      w.onSelected!.call(false);
      expect(received.length, 1);
      expect(received.first[0], 'toggle');
      expect(received.first[1], <Object?>[false]);
    });
  });
}

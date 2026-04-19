import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/segmented_button_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('SegmentedButtonBuilder', () {
    const b = SegmentedButtonBuilder();

    test('typeName is "SegmentedButton"', () {
      expect(b.typeName, 'SegmentedButton');
    });

    test('registers segments and initial selection', () {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'segments': <Object?>[
              ButtonSegment<Object?>(value: 'a', label: Text('A')),
              ButtonSegment<Object?>(value: 'b', label: Text('B')),
            ],
            'selected': <Object?>{'a'},
          },
        ),
        testContext(),
      ) as SegmentedButton<Object?>;
      expect(w.segments.length, 2);
      expect(w.segments.first.value, 'a');
      expect(w.selected, {'a'});
    });

    test('non-ButtonSegment entries are filtered out', () {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'segments': <Object?>[
              ButtonSegment<Object?>(value: 1, label: Text('x')),
              'junk',
              42,
              ButtonSegment<Object?>(value: 2, label: Text('y')),
            ],
            'selected': <Object?>{1},
          },
        ),
        testContext(),
      ) as SegmentedButton<Object?>;
      expect(w.segments.length, 2);
      expect(w.segments.map((s) => s.value).toList(), [1, 2]);
    });

    test('onSelectionChanged event dispatches with Set payload', () {
      final events = RuneEventDispatcher();
      Set<Object?>? received;
      events.register(
        'segPicked',
        (Set<Object?> sel) {
          received = sel;
        },
      );
      final ctx = testContext(events: events);
      final w = b.build(
        const ResolvedArguments(
          named: {
            'segments': <Object?>[
              ButtonSegment<Object?>(value: 'x', label: Text('X')),
              ButtonSegment<Object?>(value: 'y', label: Text('Y')),
            ],
            'selected': <Object?>{'x'},
            'onSelectionChanged': 'segPicked',
          },
        ),
        ctx,
      ) as SegmentedButton<Object?>;
      expect(w.onSelectionChanged, isNotNull);
      w.onSelectionChanged!.call({'y'});
      expect(received, {'y'});
    });

    test('multiSelectionEnabled defaults false, can be overridden', () {
      final defaulted = b.build(
        const ResolvedArguments(
          named: {
            'segments': <Object?>[
              ButtonSegment<Object?>(value: 1, label: Text('1')),
            ],
            'selected': <Object?>{1},
          },
        ),
        testContext(),
      ) as SegmentedButton<Object?>;
      expect(defaulted.multiSelectionEnabled, isFalse);

      final overridden = b.build(
        const ResolvedArguments(
          named: {
            'segments': <Object?>[
              ButtonSegment<Object?>(value: 1, label: Text('1')),
              ButtonSegment<Object?>(value: 2, label: Text('2')),
            ],
            'multiSelectionEnabled': true,
            'emptySelectionAllowed': true,
          },
        ),
        testContext(),
      ) as SegmentedButton<Object?>;
      expect(overridden.multiSelectionEnabled, isTrue);
      expect(overridden.emptySelectionAllowed, isTrue);
    });

    test('missing selected normalises to an empty set', () {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'segments': <Object?>[
              ButtonSegment<Object?>(value: 'only', label: Text('Only')),
            ],
            'emptySelectionAllowed': true,
          },
        ),
        testContext(),
      ) as SegmentedButton<Object?>;
      expect(w.selected, isEmpty);
    });
  });
}

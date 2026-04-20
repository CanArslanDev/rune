import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';
import 'package:rune_cupertino/src/widgets/cupertino_segmented_control_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('CupertinoSegmentedControlBuilder', () {
    const b = CupertinoSegmentedControlBuilder();

    test('typeName is "CupertinoSegmentedControl"', () {
      expect(b.typeName, 'CupertinoSegmentedControl');
    });

    test('requires children map', () {
      expect(
        () => b.build(
          const ResolvedArguments(
            named: {'onValueChanged': 'changed'},
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('builds from a Map<Object?, Object?> with Widget values', () {
      final children = <Object?, Object?>{
        'a': const Text('A'),
        'b': const Text('B'),
      };
      final w = b.build(
        ResolvedArguments(
          named: {
            'children': children,
            'onValueChanged': 'changed',
          },
        ),
        testContext(),
      ) as CupertinoSegmentedControl<Object>;
      expect(w.children.length, 2);
      expect(w.children.keys, containsAll(<Object>['a', 'b']));
    });

    test('throws ArgumentException on a null key', () {
      final children = <Object?, Object?>{
        'a': const Text('A'),
        null: const Text('B'),
      };
      expect(
        () => b.build(
          ResolvedArguments(
            named: {
              'children': children,
              'onValueChanged': 'changed',
            },
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('drops entries whose value is not a Widget', () {
      final children = <Object?, Object?>{
        'a': const Text('A'),
        'b': 42,
        'c': const Text('C'),
      };
      final w = b.build(
        ResolvedArguments(
          named: {
            'children': children,
            'onValueChanged': 'changed',
          },
        ),
        testContext(),
      ) as CupertinoSegmentedControl<Object>;
      expect(w.children.length, 2);
      expect(w.children.containsKey('b'), isFalse);
    });

    test('forwards groupValue and styling colors', () {
      final children = <Object?, Object?>{
        0: const Text('0'),
        1: const Text('1'),
      };
      final w = b.build(
        ResolvedArguments(
          named: {
            'children': children,
            'onValueChanged': 'changed',
            'groupValue': 1,
            'borderColor': const Color(0xFF111111),
            'selectedColor': const Color(0xFF222222),
            'unselectedColor': const Color(0xFF333333),
            'pressedColor': const Color(0xFF444444),
          },
        ),
        testContext(),
      ) as CupertinoSegmentedControl<Object>;
      expect(w.groupValue, 1);
      expect(w.borderColor, const Color(0xFF111111));
      expect(w.selectedColor, const Color(0xFF222222));
      expect(w.unselectedColor, const Color(0xFF333333));
      expect(w.pressedColor, const Color(0xFF444444));
    });

    test('onValueChanged string dispatches with the new value', () {
      final events = RuneEventDispatcher();
      final captured = <List<Object?>>[];
      events.setCatchAllHandler((name, args) {
        if (name == 'changed') captured.add(args);
      });
      final children = <Object?, Object?>{
        'a': const Text('A'),
        'b': const Text('B'),
      };
      final w = b.build(
        ResolvedArguments(
          named: {
            'children': children,
            'onValueChanged': 'changed',
          },
        ),
        testContext(events: events),
      ) as CupertinoSegmentedControl<Object>;
      w.onValueChanged('b');
      expect(captured, [
        ['b'],
      ]);
    });
  });
}

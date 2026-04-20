import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';
import 'package:rune_cupertino/src/widgets/cupertino_slider_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('CupertinoSliderBuilder', () {
    const b = CupertinoSliderBuilder();

    test('typeName is "CupertinoSlider"', () {
      expect(b.typeName, 'CupertinoSlider');
    });

    test('requires value', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('coerces num value to double and applies min/max defaults', () {
      final w = b.build(
        const ResolvedArguments(named: {'value': 0.3}),
        testContext(),
      ) as CupertinoSlider;
      expect(w.value, 0.3);
      expect(w.min, 0.0);
      expect(w.max, 1.0);
    });

    test('forwards custom min/max and divisions', () {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'value': 5,
            'min': 0,
            'max': 10,
            'divisions': 10,
          },
        ),
        testContext(),
      ) as CupertinoSlider;
      expect(w.value, 5.0);
      expect(w.min, 0.0);
      expect(w.max, 10.0);
      expect(w.divisions, 10);
    });

    test('onChanged dispatches with the new double', () {
      final events = RuneEventDispatcher();
      final captured = <List<Object?>>[];
      events.setCatchAllHandler((name, args) {
        if (name == 'slid') captured.add(args);
      });
      final ctx = testContext(events: events);
      final w = b.build(
        const ResolvedArguments(
          named: {'value': 0.0, 'onChanged': 'slid'},
        ),
        ctx,
      ) as CupertinoSlider;
      w.onChanged!.call(0.7);
      expect(captured, [
        [0.7],
      ]);
    });

    test('missing onChanged disables the slider', () {
      final w = b.build(
        const ResolvedArguments(named: {'value': 0.5}),
        testContext(),
      ) as CupertinoSlider;
      expect(w.onChanged, isNull);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/checkbox_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('CheckboxBuilder', () {
    const b = CheckboxBuilder();

    test('typeName is "Checkbox"', () {
      expect(b.typeName, 'Checkbox');
    });

    test('value: true reflects', () {
      final w = b.build(
        const ResolvedArguments(named: {'value': true}),
        testContext(),
      ) as Checkbox;
      expect(w.value, isTrue);
      expect(w.tristate, isFalse);
    });

    test('toggle fires event with new bool', () {
      final events = RuneEventDispatcher();
      final captured = <List<Object?>>[];
      events.setCatchAllHandler((name, args) {
        if (name == 'agree') captured.add(args);
      });
      final w = b.build(
        const ResolvedArguments(
          named: {'value': false, 'onChanged': 'agree'},
        ),
        testContext(events: events),
      ) as Checkbox;
      expect(w.onChanged, isNotNull);
      w.onChanged!.call(true);
      expect(captured, [
        [true],
      ]);
    });

    test('tristate: true with null value forwards null on cycle', () {
      final events = RuneEventDispatcher();
      final captured = <List<Object?>>[];
      events.setCatchAllHandler((name, args) {
        if (name == 'opt') captured.add(args);
      });
      final w = b.build(
        const ResolvedArguments(
          named: {
            'value': null,
            'tristate': true,
            'onChanged': 'opt',
          },
        ),
        testContext(events: events),
      ) as Checkbox;
      expect(w.tristate, isTrue);
      expect(w.value, isNull);
      // Flutter cycles null -> false -> true -> null under tristate. We
      // simulate by calling the callback directly with each value.
      w.onChanged!.call(false);
      w.onChanged!.call(true);
      w.onChanged!.call(null);
      expect(captured, [
        [false],
        [true],
        [null],
      ]);
    });

    test('missing onChanged disables the checkbox', () {
      final events = RuneEventDispatcher();
      var observed = false;
      events.setCatchAllHandler((_, __) => observed = true);
      final w = b.build(
        const ResolvedArguments(named: {'value': false}),
        testContext(events: events),
      ) as Checkbox;
      expect(w.onChanged, isNull);
      expect(observed, isFalse);
    });
  });
}

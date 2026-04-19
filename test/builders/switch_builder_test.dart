import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/switch_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('SwitchBuilder', () {
    const b = SwitchBuilder();

    test('typeName is "Switch"', () {
      expect(b.typeName, 'Switch');
    });

    test('off by default when no value given', () {
      final w =
          b.build(ResolvedArguments.empty, testContext()) as Switch;
      expect(w.value, isFalse);
    });

    test('value: true reflects', () {
      final w = b.build(
        const ResolvedArguments(named: {'value': true}),
        testContext(),
      ) as Switch;
      expect(w.value, isTrue);
    });

    test('toggling fires event with new bool', () {
      final events = RuneEventDispatcher();
      final captured = <List<Object?>>[];
      events.setCatchAllHandler((name, args) {
        if (name == 'themeChanged') captured.add(args);
      });
      final ctx = testContext(events: events);
      final w = b.build(
        const ResolvedArguments(
          named: {'value': false, 'onChanged': 'themeChanged'},
        ),
        ctx,
      ) as Switch;
      expect(w.onChanged, isNotNull);
      w.onChanged!.call(true);
      expect(captured, [
        [true],
      ]);
    });

    test('missing onChanged disables the switch', () {
      final events = RuneEventDispatcher();
      var observed = false;
      events.setCatchAllHandler((_, __) => observed = true);
      final w = b.build(
        const ResolvedArguments(named: {'value': true}),
        testContext(events: events),
      ) as Switch;
      expect(w.onChanged, isNull);
      expect(observed, isFalse);
    });
  });
}

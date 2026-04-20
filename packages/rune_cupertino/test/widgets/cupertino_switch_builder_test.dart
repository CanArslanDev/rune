import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';
import 'package:rune_cupertino/src/widgets/cupertino_switch_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('CupertinoSwitchBuilder', () {
    const b = CupertinoSwitchBuilder();

    test('typeName is "CupertinoSwitch"', () {
      expect(b.typeName, 'CupertinoSwitch');
    });

    test('defaults value to false when absent', () {
      final w = b.build(
        ResolvedArguments.empty,
        testContext(),
      ) as CupertinoSwitch;
      expect(w.value, isFalse);
    });

    test('reflects explicit value', () {
      final w = b.build(
        const ResolvedArguments(named: {'value': true}),
        testContext(),
      ) as CupertinoSwitch;
      expect(w.value, isTrue);
    });

    test('toggling forwards the new bool through onChanged event', () {
      final events = RuneEventDispatcher();
      final captured = <List<Object?>>[];
      events.setCatchAllHandler((name, args) {
        if (name == 'flipped') captured.add(args);
      });
      final ctx = testContext(events: events);
      final w = b.build(
        const ResolvedArguments(
          named: {'value': false, 'onChanged': 'flipped'},
        ),
        ctx,
      ) as CupertinoSwitch;
      w.onChanged!.call(true);
      expect(captured, [
        [true],
      ]);
    });

    test('missing onChanged disables the switch', () {
      final w = b.build(
        const ResolvedArguments(named: {'value': true}),
        testContext(),
      ) as CupertinoSwitch;
      expect(w.onChanged, isNull);
    });
  });
}

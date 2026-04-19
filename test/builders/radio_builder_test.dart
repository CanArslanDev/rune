import 'package:flutter/material.dart' show MaterialApp, Radio, Scaffold, Widget;
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/radio_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

Widget _harness(Widget built) => MaterialApp(home: Scaffold(body: built));

void main() {
  group('RadioBuilder', () {
    const b = RadioBuilder();

    test('typeName is "Radio"', () {
      expect(b.typeName, 'Radio');
    });

    testWidgets('value == groupValue renders selected', (tester) async {
      final built = b.build(
        const ResolvedArguments(named: {'value': 1, 'groupValue': 1}),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      final radio = tester.widget<Radio<Object?>>(find.byType(Radio<Object?>));
      expect(radio.value, 1);
      // RadioBuilder intentionally keeps the direct groupValue contract;
      // see the builder's class dartdoc for rationale.
      // ignore: deprecated_member_use
      expect(radio.groupValue, 1);
    });

    testWidgets('value != groupValue renders unselected', (tester) async {
      final built = b.build(
        const ResolvedArguments(named: {'value': 2, 'groupValue': 1}),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      final radio = tester.widget<Radio<Object?>>(find.byType(Radio<Object?>));
      expect(radio.value, 2);
      // ignore: deprecated_member_use
      expect(radio.groupValue, 1);
    });

    test('missing value throws ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('explicit value: null does NOT throw', () {
      // The distinction: absent value throws, but an explicit null
      // is legitimate for Radio<Object?> and must not throw.
      final w = b.build(
        const ResolvedArguments(named: {'value': null}),
        testContext(),
      ) as Radio<Object?>;
      expect(w.value, isNull);
    });

    testWidgets('tap dispatches this radios own value', (tester) async {
      final events = RuneEventDispatcher();
      final captured = <List<Object?>>[];
      events.setCatchAllHandler((name, args) {
        if (name == 'picked') captured.add(args);
      });
      final built = b.build(
        const ResolvedArguments(
          named: {
            'value': 'alpha',
            'groupValue': 'beta',
            'onChanged': 'picked',
          },
        ),
        testContext(events: events),
      );
      await tester.pumpWidget(_harness(built));
      await tester.tap(find.byType(Radio<Object?>));
      await tester.pump();
      expect(captured, [
        ['alpha'],
      ]);
    });

    testWidgets('toggleable: true + tap on selected dispatches null',
        (tester) async {
      final events = RuneEventDispatcher();
      final captured = <List<Object?>>[];
      events.setCatchAllHandler((name, args) {
        if (name == 'picked') captured.add(args);
      });
      final built = b.build(
        const ResolvedArguments(
          named: {
            'value': 1,
            'groupValue': 1,
            'toggleable': true,
            'onChanged': 'picked',
          },
        ),
        testContext(events: events),
      );
      await tester.pumpWidget(_harness(built));
      final radio = tester.widget<Radio<Object?>>(find.byType(Radio<Object?>));
      expect(radio.toggleable, isTrue);
      await tester.tap(find.byType(Radio<Object?>));
      await tester.pump();
      expect(captured, [
        [null],
      ]);
    });

    test('missing onChanged leaves callback null', () {
      final w = b.build(
        const ResolvedArguments(named: {'value': 1, 'groupValue': 1}),
        testContext(),
      ) as Radio<Object?>;
      // RadioBuilder wires onChanged directly rather than through RadioGroup.
      // ignore: deprecated_member_use
      expect(w.onChanged, isNull);
    });
  });
}

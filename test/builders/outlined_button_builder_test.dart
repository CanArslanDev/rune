import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/outlined_button_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('OutlinedButtonBuilder', () {
    const b = OutlinedButtonBuilder();

    test('typeName is "OutlinedButton"', () {
      expect(b.typeName, 'OutlinedButton');
    });

    test('wraps onPressed string into a VoidCallback that dispatches', () {
      final events = RuneEventDispatcher();
      var count = 0;
      events.register('cancel', () => count++);
      final ctx = testContext(events: events);
      final w = b.build(
        const ResolvedArguments(
          named: {'onPressed': 'cancel', 'child': Text('Cancel')},
        ),
        ctx,
      ) as OutlinedButton;
      expect(w.onPressed, isNotNull);
      w.onPressed!.call();
      w.onPressed!.call();
      expect(count, 2);
    });

    test('missing onPressed leaves button disabled', () {
      final w = b.build(
        const ResolvedArguments(named: {'child': Text('x')}),
        testContext(),
      ) as OutlinedButton;
      expect(w.onPressed, isNull);
    });

    test('missing child falls back to empty SizedBox', () {
      final w = b.build(
        ResolvedArguments.empty,
        testContext(),
      ) as OutlinedButton;
      expect(w.child, isA<SizedBox>());
    });

    test('forwards child widget identity', () {
      const child = Text('K');
      final w = b.build(
        const ResolvedArguments(named: {'child': child}),
        testContext(),
      ) as OutlinedButton;
      expect(w.child, same(child));
    });
  });
}

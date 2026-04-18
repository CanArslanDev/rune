import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/elevated_button_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('ElevatedButtonBuilder', () {
    const b = ElevatedButtonBuilder();

    test('typeName is "ElevatedButton"', () {
      expect(b.typeName, 'ElevatedButton');
    });

    test('wraps onPressed string into a VoidCallback that dispatches', () {
      final events = RuneEventDispatcher();
      String? fired;
      events.register('submit', () => fired = 'submit');
      final ctx = testContext(events: events);
      const child = Text('Send');
      final w = b.build(
        const ResolvedArguments(
          named: {'onPressed': 'submit', 'child': child},
        ),
        ctx,
      ) as ElevatedButton;
      expect(w.onPressed, isNotNull);
      w.onPressed!.call();
      expect(fired, 'submit');
      expect(w.child, same(child));
    });

    test('missing onPressed leaves button disabled (onPressed null)', () {
      final w = b.build(
        const ResolvedArguments(named: {'child': Text('x')}),
        testContext(),
      ) as ElevatedButton;
      expect(w.onPressed, isNull);
    });

    test('missing child still builds (onPressed fires through)', () {
      final events = RuneEventDispatcher();
      var count = 0;
      events.register('tap', () => count++);
      final ctx = testContext(events: events);
      final w = b.build(
        const ResolvedArguments(named: {'onPressed': 'tap'}),
        ctx,
      ) as ElevatedButton;
      w.onPressed!.call();
      expect(count, 1);
    });
  });
}

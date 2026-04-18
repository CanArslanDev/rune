import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/text_button_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('TextButtonBuilder', () {
    const b = TextButtonBuilder();

    test('typeName is "TextButton"', () {
      expect(b.typeName, 'TextButton');
    });

    test('wraps onPressed string into a VoidCallback that dispatches', () {
      final events = RuneEventDispatcher();
      String? fired;
      events.register('cancel', () => fired = 'cancel');
      final ctx = testContext(events: events);
      const child = Text('Cancel');
      final w = b.build(
        const ResolvedArguments(
          named: {'onPressed': 'cancel', 'child': child},
        ),
        ctx,
      ) as TextButton;
      expect(w.onPressed, isNotNull);
      w.onPressed!.call();
      expect(fired, 'cancel');
      expect(w.child, same(child));
    });

    test('missing onPressed leaves button disabled', () {
      final w = b.build(
        const ResolvedArguments(named: {'child': Text('x')}),
        testContext(),
      ) as TextButton;
      expect(w.onPressed, isNull);
    });
  });
}

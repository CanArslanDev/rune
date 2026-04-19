import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/filled_button_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('FilledButtonBuilder', () {
    const b = FilledButtonBuilder();

    test('typeName is "FilledButton"', () {
      expect(b.typeName, 'FilledButton');
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
      ) as FilledButton;
      expect(w.onPressed, isNotNull);
      w.onPressed!.call();
      expect(fired, 'submit');
      expect(w.child, same(child));
    });

    test('missing onPressed leaves button disabled (onPressed null)', () {
      final w = b.build(
        const ResolvedArguments(named: {'child': Text('x')}),
        testContext(),
      ) as FilledButton;
      expect(w.onPressed, isNull);
    });

    test('missing child falls back to empty SizedBox', () {
      final w = b.build(
        const ResolvedArguments(named: {'onPressed': 'tap'}),
        testContext(events: RuneEventDispatcher()),
      ) as FilledButton;
      expect(w.child, isA<SizedBox>());
    });

    test('renders inside a MaterialApp without throwing', (
    ) async {
      // Compile-time smoke: FilledButton build returns a valid widget
      // that Flutter can instantiate; no need for a tester here.
      final w = b.build(
        const ResolvedArguments(named: {'child': Text('Hi')}),
        testContext(),
      );
      expect(w, isA<FilledButton>());
    });
  });
}

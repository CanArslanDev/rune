import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';
import 'package:rune_cupertino/src/widgets/cupertino_button_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('CupertinoButtonBuilder', () {
    const b = CupertinoButtonBuilder();

    test('typeName is "CupertinoButton"', () {
      expect(b.typeName, 'CupertinoButton');
    });

    test('requires child and throws ArgumentException when absent', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('wraps onPressed string into a dispatching VoidCallback', () {
      final events = RuneEventDispatcher();
      String? fired;
      events.register('tapped', () => fired = 'tapped');
      final ctx = testContext(events: events);
      const child = Text('Go');
      final w = b.build(
        const ResolvedArguments(
          named: {'onPressed': 'tapped', 'child': child},
        ),
        ctx,
      ) as CupertinoButton;
      expect(w.onPressed, isNotNull);
      w.onPressed!.call();
      expect(fired, 'tapped');
      expect(w.child, same(child));
    });

    test('missing onPressed leaves the button disabled', () {
      final w = b.build(
        const ResolvedArguments(named: {'child': Text('Go')}),
        testContext(),
      ) as CupertinoButton;
      expect(w.onPressed, isNull);
    });

    test('color and padding are forwarded when supplied', () {
      const pad = EdgeInsets.all(12);
      final w = b.build(
        const ResolvedArguments(
          named: {
            'child': Text('x'),
            'color': Color(0xFF123456),
            'padding': pad,
            'pressedOpacity': 0.5,
          },
        ),
        testContext(),
      ) as CupertinoButton;
      expect(w.color, const Color(0xFF123456));
      expect(w.padding, pad);
      expect(w.pressedOpacity, 0.5);
    });
  });
}

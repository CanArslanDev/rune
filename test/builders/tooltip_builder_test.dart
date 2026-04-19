import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/tooltip_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('TooltipBuilder', () {
    const b = TooltipBuilder();

    test('typeName is "Tooltip"', () {
      expect(b.typeName, 'Tooltip');
    });

    test('message + child plumb through', () {
      const child = Icon(Icons.info);
      final w = b.build(
        const ResolvedArguments(
          named: {'message': 'hint', 'child': child},
        ),
        testContext(),
      ) as Tooltip;
      expect(w.message, 'hint');
      expect(w.child, same(child));
      expect(w.preferBelow, isTrue);
    });

    test('missing message throws ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('preferBelow + waitDuration + showDuration + padding plumb through',
        () {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'message': 'hint',
            'preferBelow': false,
            'waitDuration': Duration(seconds: 1),
            'showDuration': Duration(seconds: 3),
            'padding': EdgeInsets.all(6),
          },
        ),
        testContext(),
      ) as Tooltip;
      expect(w.message, 'hint');
      expect(w.preferBelow, isFalse);
      expect(w.waitDuration, const Duration(seconds: 1));
      expect(w.showDuration, const Duration(seconds: 3));
      expect(w.padding, const EdgeInsets.all(6));
    });
  });
}

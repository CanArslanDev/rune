import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/animated_switcher_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('AnimatedSwitcherBuilder', () {
    const b = AnimatedSwitcherBuilder();

    test('typeName is "AnimatedSwitcher"', () {
      expect(b.typeName, 'AnimatedSwitcher');
    });

    test('required duration + child plumb through', () {
      const child = Text('a');
      final w = b.build(
        const ResolvedArguments(
          named: {
            'duration': Duration(milliseconds: 300),
            'child': child,
          },
        ),
        testContext(),
      ) as AnimatedSwitcher;
      expect(w.duration, const Duration(milliseconds: 300));
      expect(w.child, same(child));
      expect(w.switchInCurve, same(Curves.linear));
      expect(w.switchOutCurve, same(Curves.linear));
      expect(w.reverseDuration, isNull);
    });

    test('missing duration throws ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('reverseDuration + switchInCurve + switchOutCurve plumb through', () {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'duration': Duration(milliseconds: 200),
            'reverseDuration': Duration(milliseconds: 150),
            'switchInCurve': Curves.easeIn,
            'switchOutCurve': Curves.easeOut,
          },
        ),
        testContext(),
      ) as AnimatedSwitcher;
      expect(w.reverseDuration, const Duration(milliseconds: 150));
      expect(w.switchInCurve, same(Curves.easeIn));
      expect(w.switchOutCurve, same(Curves.easeOut));
    });
  });
}

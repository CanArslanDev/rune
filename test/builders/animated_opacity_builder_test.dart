import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/animated_opacity_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('AnimatedOpacityBuilder', () {
    const b = AnimatedOpacityBuilder();

    test('typeName is "AnimatedOpacity"', () {
      expect(b.typeName, 'AnimatedOpacity');
    });

    test('opacity + duration + child plumb through', () {
      const child = Text('x');
      final w = b.build(
        const ResolvedArguments(
          named: {
            'opacity': 0.5,
            'duration': Duration(milliseconds: 250),
            'child': child,
          },
        ),
        testContext(),
      ) as AnimatedOpacity;
      expect(w.opacity, 0.5);
      expect(w.duration, const Duration(milliseconds: 250));
      expect(w.child, same(child));
    });

    test('integer opacity coerces to double', () {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'opacity': 1,
            'duration': Duration(milliseconds: 100),
          },
        ),
        testContext(),
      ) as AnimatedOpacity;
      expect(w.opacity, 1.0);
    });

    test('curve defaults to Curves.linear; explicit curve plumbs through', () {
      final w1 = b.build(
        const ResolvedArguments(
          named: {
            'opacity': 0.2,
            'duration': Duration(milliseconds: 100),
          },
        ),
        testContext(),
      ) as AnimatedOpacity;
      expect(w1.curve, same(Curves.linear));

      final w2 = b.build(
        const ResolvedArguments(
          named: {
            'opacity': 0.2,
            'duration': Duration(milliseconds: 100),
            'curve': Curves.easeOut,
          },
        ),
        testContext(),
      ) as AnimatedOpacity;
      expect(w2.curve, same(Curves.easeOut));
    });

    test('missing opacity throws ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(
            named: {'duration': Duration(milliseconds: 100)},
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('missing duration throws ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(named: {'opacity': 0.5}),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}

import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/sweep_gradient_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('SweepGradientBuilder', () {
    const b = SweepGradientBuilder();

    test('typeName/constructorName', () {
      expect(b.typeName, 'SweepGradient');
      expect(b.constructorName, isNull);
    });

    test('colors list with default center and full-circle sweep', () {
      final result = b.build(
        const ResolvedArguments(
          named: {
            'colors': <Object?>[Color(0xFF000000), Color(0xFFFFFFFF)],
          },
        ),
        testContext(),
      );
      expect(result.center, Alignment.center);
      expect(result.startAngle, 0);
      expect(result.endAngle, closeTo(math.pi * 2, 0.0001));
    });

    test('custom start/end angles pass through', () {
      final result = b.build(
        const ResolvedArguments(
          named: {
            'colors': <Object?>[Color(0xFF000000), Color(0xFFFFFFFF)],
            'startAngle': 0.5,
            'endAngle': 1.5,
          },
        ),
        testContext(),
      );
      expect(result.startAngle, 0.5);
      expect(result.endAngle, 1.5);
    });

    test('missing colors throws ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}

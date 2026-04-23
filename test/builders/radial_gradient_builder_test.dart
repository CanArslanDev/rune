import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/radial_gradient_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('RadialGradientBuilder', () {
    const b = RadialGradientBuilder();

    test('typeName/constructorName', () {
      expect(b.typeName, 'RadialGradient');
      expect(b.constructorName, isNull);
    });

    test('colors list with default center + radius', () {
      final result = b.build(
        const ResolvedArguments(
          named: {
            'colors': <Object?>[Color(0xFF000000), Color(0xFFFFFFFF)],
          },
        ),
        testContext(),
      );
      expect(
        result,
        const RadialGradient(
          colors: [Color(0xFF000000), Color(0xFFFFFFFF)],
        ),
      );
    });

    test('center + radius overrides defaults', () {
      final result = b.build(
        const ResolvedArguments(
          named: {
            'colors': <Object?>[Color(0xFF000000), Color(0xFFFFFFFF)],
            'center': Alignment.topLeft,
            'radius': 0.8,
          },
        ),
        testContext(),
      );
      expect(result.center, Alignment.topLeft);
      expect(result.radius, 0.8);
    });

    test('missing colors throws ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/linear_gradient_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('LinearGradientBuilder', () {
    const b = LinearGradientBuilder();

    test('typeName/constructorName', () {
      expect(b.typeName, 'LinearGradient');
      expect(b.constructorName, isNull);
    });

    test('colors list + default centerLeft→centerRight direction', () {
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
        const LinearGradient(
          colors: [Color(0xFF000000), Color(0xFFFFFFFF)],
        ),
      );
    });

    test('begin + end override defaults', () {
      final result = b.build(
        const ResolvedArguments(
          named: {
            'colors': <Object?>[Color(0xFFFF0000), Color(0xFF0000FF)],
            'begin': Alignment.topLeft,
            'end': Alignment.bottomRight,
          },
        ),
        testContext(),
      );
      expect(
        result,
        const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF0000), Color(0xFF0000FF)],
        ),
      );
    });

    test('stops list coerces mixed int/double entries', () {
      final result = b.build(
        const ResolvedArguments(
          named: {
            'colors': <Object?>[Color(0xFF000000), Color(0xFFFFFFFF)],
            'stops': <Object?>[0, 1],
          },
        ),
        testContext(),
      );
      expect(result.stops, [0.0, 1.0]);
    });

    test('missing colors throws ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}

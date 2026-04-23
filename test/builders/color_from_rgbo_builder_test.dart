import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/color_from_rgbo_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('ColorFromRgboBuilder', () {
    const b = ColorFromRgboBuilder();

    test('typeName/constructorName', () {
      expect(b.typeName, 'Color');
      expect(b.constructorName, 'fromRGBO');
    });

    test('builds opaque red from three ints + double opacity', () {
      final result = b.build(
        const ResolvedArguments(positional: [255, 0, 0, 0.5]),
        testContext(),
      );
      expect(result, const Color.fromRGBO(255, 0, 0, 0.5));
    });

    test('accepts int opacity coerced to double', () {
      final result = b.build(
        const ResolvedArguments(positional: [0, 0, 255, 1]),
        testContext(),
      );
      expect(result, const Color.fromRGBO(0, 0, 255, 1));
    });

    test('missing opacity throws ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(positional: [255, 255, 255]),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}

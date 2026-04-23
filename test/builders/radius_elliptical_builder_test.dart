import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/radius_elliptical_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('RadiusEllipticalBuilder', () {
    const b = RadiusEllipticalBuilder();

    test('typeName/constructorName', () {
      expect(b.typeName, 'Radius');
      expect(b.constructorName, 'elliptical');
    });

    test('builds elliptical Radius from two positional nums', () {
      final result = b.build(
        const ResolvedArguments(positional: [6, 10]),
        testContext(),
      );
      expect(result, const Radius.elliptical(6, 10));
    });

    test('coerces mixed int/double input', () {
      final result = b.build(
        const ResolvedArguments(positional: [4.5, 9]),
        testContext(),
      );
      expect(result, const Radius.elliptical(4.5, 9));
    });

    test('missing second positional throws ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(positional: [4]),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}

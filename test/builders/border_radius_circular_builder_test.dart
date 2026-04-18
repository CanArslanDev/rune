import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/border_radius_circular_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('BorderRadiusCircularBuilder', () {
    const b = BorderRadiusCircularBuilder();

    test('typeName/constructorName', () {
      expect(b.typeName, 'BorderRadius');
      expect(b.constructorName, 'circular');
    });

    test('builds from positional int', () {
      final result = b.build(
        const ResolvedArguments(positional: [12]),
        testContext(),
      );
      expect(result, BorderRadius.circular(12));
    });

    test('builds from positional double', () {
      final result = b.build(
        const ResolvedArguments(positional: [8.5]),
        testContext(),
      );
      expect(result, BorderRadius.circular(8.5));
    });

    test('missing positional throws ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}

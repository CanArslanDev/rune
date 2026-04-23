import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/radius_circular_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('RadiusCircularBuilder', () {
    const b = RadiusCircularBuilder();

    test('typeName/constructorName', () {
      expect(b.typeName, 'Radius');
      expect(b.constructorName, 'circular');
    });

    test('builds circular Radius from int', () {
      final result = b.build(
        const ResolvedArguments(positional: [8]),
        testContext(),
      );
      expect(result, const Radius.circular(8));
    });

    test('accepts double value', () {
      final result = b.build(
        const ResolvedArguments(positional: [12.5]),
        testContext(),
      );
      expect(result, const Radius.circular(12.5));
    });

    test('missing positional throws ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}

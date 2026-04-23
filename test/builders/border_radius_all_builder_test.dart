import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/border_radius_all_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('BorderRadiusAllBuilder', () {
    const b = BorderRadiusAllBuilder();

    test('typeName/constructorName', () {
      expect(b.typeName, 'BorderRadius');
      expect(b.constructorName, 'all');
    });

    test('builds BorderRadius.all from a Radius', () {
      final result = b.build(
        const ResolvedArguments(positional: [Radius.circular(8)]),
        testContext(),
      );
      expect(result, const BorderRadius.all(Radius.circular(8)));
    });

    test('missing positional throws ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}

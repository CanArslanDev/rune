import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/edge_insets_symmetric_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('EdgeInsetsSymmetricBuilder', () {
    const b = EdgeInsetsSymmetricBuilder();

    test('typeName/constructorName', () {
      expect(b.typeName, 'EdgeInsets');
      expect(b.constructorName, 'symmetric');
    });

    test('builds with both horizontal and vertical', () {
      final result = b.build(
        const ResolvedArguments(named: {'horizontal': 16, 'vertical': 8}),
        testContext(),
      );
      expect(result, const EdgeInsets.symmetric(horizontal: 16, vertical: 8));
    });

    test('defaults missing axis to 0', () {
      final result = b.build(
        const ResolvedArguments(named: {'horizontal': 12}),
        testContext(),
      );
      expect(result, const EdgeInsets.symmetric(horizontal: 12));
    });

    test('all-missing produces EdgeInsets.zero-equivalent', () {
      final result = b.build(const ResolvedArguments(), testContext());
      expect(result, EdgeInsets.zero);
    });

    test('accepts double values', () {
      final result = b.build(
        const ResolvedArguments(named: {'horizontal': 2.5, 'vertical': 1.5}),
        testContext(),
      );
      expect(
        result,
        const EdgeInsets.symmetric(horizontal: 2.5, vertical: 1.5),
      );
    });
  });
}

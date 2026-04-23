import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/border_radius_only_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('BorderRadiusOnlyBuilder', () {
    const b = BorderRadiusOnlyBuilder();

    test('typeName/constructorName', () {
      expect(b.typeName, 'BorderRadius');
      expect(b.constructorName, 'only');
    });

    test('omitted corners default to Radius.zero', () {
      final result = b.build(
        const ResolvedArguments(
          named: {
            'topLeft': Radius.circular(8),
          },
        ),
        testContext(),
      );
      expect(
        result,
        const BorderRadius.only(topLeft: Radius.circular(8)),
      );
    });

    test('all four corners pass through', () {
      final result = b.build(
        const ResolvedArguments(
          named: {
            'topLeft': Radius.circular(1),
            'topRight': Radius.circular(2),
            'bottomLeft': Radius.circular(3),
            'bottomRight': Radius.circular(4),
          },
        ),
        testContext(),
      );
      expect(
        result,
        const BorderRadius.only(
          topLeft: Radius.circular(1),
          topRight: Radius.circular(2),
          bottomLeft: Radius.circular(3),
          bottomRight: Radius.circular(4),
        ),
      );
    });

    test('zero named args returns BorderRadius.zero', () {
      final result = b.build(ResolvedArguments.empty, testContext());
      expect(result, BorderRadius.zero);
    });
  });
}

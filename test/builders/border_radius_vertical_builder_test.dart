import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/border_radius_vertical_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('BorderRadiusVerticalBuilder', () {
    const b = BorderRadiusVerticalBuilder();

    test('typeName/constructorName', () {
      expect(b.typeName, 'BorderRadius');
      expect(b.constructorName, 'vertical');
    });

    test('top + bottom both supplied', () {
      final result = b.build(
        const ResolvedArguments(
          named: {
            'top': Radius.circular(4),
            'bottom': Radius.circular(8),
          },
        ),
        testContext(),
      );
      expect(
        result,
        const BorderRadius.vertical(
          top: Radius.circular(4),
          bottom: Radius.circular(8),
        ),
      );
    });

    test('omitted arms default to Radius.zero', () {
      final result = b.build(
        const ResolvedArguments(
          named: {
            'top': Radius.circular(12),
          },
        ),
        testContext(),
      );
      expect(
        result,
        const BorderRadius.vertical(top: Radius.circular(12)),
      );
    });

    test('no args returns BorderRadius.zero', () {
      final result = b.build(ResolvedArguments.empty, testContext());
      expect(result, BorderRadius.zero);
    });
  });
}

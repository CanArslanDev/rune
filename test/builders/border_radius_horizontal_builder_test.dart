import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/border_radius_horizontal_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('BorderRadiusHorizontalBuilder', () {
    const b = BorderRadiusHorizontalBuilder();

    test('typeName/constructorName', () {
      expect(b.typeName, 'BorderRadius');
      expect(b.constructorName, 'horizontal');
    });

    test('left + right both supplied', () {
      final result = b.build(
        const ResolvedArguments(
          named: {
            'left': Radius.circular(3),
            'right': Radius.circular(6),
          },
        ),
        testContext(),
      );
      expect(
        result,
        const BorderRadius.horizontal(
          left: Radius.circular(3),
          right: Radius.circular(6),
        ),
      );
    });

    test('omitted arms default to Radius.zero', () {
      final result = b.build(
        const ResolvedArguments(
          named: {
            'right': Radius.circular(10),
          },
        ),
        testContext(),
      );
      expect(
        result,
        const BorderRadius.horizontal(right: Radius.circular(10)),
      );
    });

    test('no args returns BorderRadius.zero', () {
      final result = b.build(ResolvedArguments.empty, testContext());
      expect(result, BorderRadius.zero);
    });
  });
}

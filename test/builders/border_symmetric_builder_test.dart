import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/border_symmetric_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('BorderSymmetricBuilder', () {
    const b = BorderSymmetricBuilder();

    test('typeName/constructorName', () {
      expect(b.typeName, 'Border');
      expect(b.constructorName, 'symmetric');
    });

    test('vertical + horizontal both provided', () {
      final result = b.build(
        const ResolvedArguments(
          named: {
            'vertical': BorderSide(width: 3),
            'horizontal': BorderSide(width: 5),
          },
        ),
        testContext(),
      );
      expect(
        result,
        const Border.symmetric(
          vertical: BorderSide(width: 3),
          horizontal: BorderSide(width: 5),
        ),
      );
    });

    test('omitted sides default to BorderSide.none', () {
      final result = b.build(
        const ResolvedArguments(
          named: {'horizontal': BorderSide(width: 5)},
        ),
        testContext(),
      );
      expect(
        result,
        const Border.symmetric(horizontal: BorderSide(width: 5)),
      );
    });

    test('no args returns a zero Border.symmetric', () {
      final result = b.build(ResolvedArguments.empty, testContext());
      expect(result, const Border.symmetric());
    });
  });
}

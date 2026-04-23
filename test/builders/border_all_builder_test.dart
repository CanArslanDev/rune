import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/border_all_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('BorderAllBuilder', () {
    const b = BorderAllBuilder();

    test('typeName/constructorName', () {
      expect(b.typeName, 'Border');
      expect(b.constructorName, 'all');
    });

    test('defaults: black, width 1, solid style', () {
      final result = b.build(ResolvedArguments.empty, testContext());
      expect(result, Border.all());
    });

    test('custom color + width', () {
      final result = b.build(
        const ResolvedArguments(
          named: {
            'color': Color(0xFFFF0000),
            'width': 2.5,
          },
        ),
        testContext(),
      );
      expect(
        result,
        Border.all(color: const Color(0xFFFF0000), width: 2.5),
      );
    });

    test('int width coerces to double', () {
      final result = b.build(
        const ResolvedArguments(named: {'width': 3}),
        testContext(),
      );
      expect(result, Border.all(width: 3));
    });

  });
}

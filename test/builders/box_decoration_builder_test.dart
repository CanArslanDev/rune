import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/box_decoration_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('BoxDecorationBuilder', () {
    const b = BoxDecorationBuilder();

    test('typeName/constructorName', () {
      expect(b.typeName, 'BoxDecoration');
      expect(b.constructorName, isNull);
    });

    test('builds empty decoration when no args', () {
      final result = b.build(const ResolvedArguments(), testContext());
      expect(result, const BoxDecoration());
    });

    test('applies color + borderRadius', () {
      final BoxDecoration result = b.build(
        ResolvedArguments(
          named: {
            'color': const Color(0xFF0000FF),
            'borderRadius': BorderRadius.circular(12),
          },
        ),
        testContext(),
      );
      expect(result.color, const Color(0xFF0000FF));
      expect(result.borderRadius, BorderRadius.circular(12));
    });

    test('applies shape default rectangle when omitted', () {
      final BoxDecoration result =
          b.build(const ResolvedArguments(), testContext());
      expect(result.shape, BoxShape.rectangle);
    });

    test('applies circle shape when supplied', () {
      final BoxDecoration result = b.build(
        const ResolvedArguments(named: {'shape': BoxShape.circle}),
        testContext(),
      );
      expect(result.shape, BoxShape.circle);
    });
  });
}

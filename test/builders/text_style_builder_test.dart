import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/text_style_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('TextStyleBuilder', () {
    const b = TextStyleBuilder();

    test('typeName/constructorName', () {
      expect(b.typeName, 'TextStyle');
      expect(b.constructorName, isNull);
    });

    test('builds empty TextStyle when no args', () {
      final result = b.build(ResolvedArguments.empty, testContext());
      expect(result, const TextStyle());
    });

    test('applies fontSize/color/fontWeight', () {
      final result = b.build(
        const ResolvedArguments(
          named: {
            'fontSize': 16,
            'color': Color(0xFFFF0000),
            'fontWeight': FontWeight.bold,
          },
        ),
        testContext(),
      );
      expect(result.fontSize, 16.0);
      expect(result.color, const Color(0xFFFF0000));
      expect(result.fontWeight, FontWeight.bold);
    });

    test('applies fontFamily + letterSpacing + height + fontStyle', () {
      final result = b.build(
        const ResolvedArguments(
          named: {
            'fontFamily': 'Roboto',
            'letterSpacing': 0.5,
            'height': 1.4,
            'fontStyle': FontStyle.italic,
          },
        ),
        testContext(),
      );
      expect(result.fontFamily, 'Roboto');
      expect(result.letterSpacing, 0.5);
      expect(result.height, 1.4);
      expect(result.fontStyle, FontStyle.italic);
    });

    test('int fontSize coerces to double', () {
      final result = b.build(
        const ResolvedArguments(named: {'fontSize': 20}),
        testContext(),
      );
      expect(result.fontSize, 20.0);
    });
  });
}

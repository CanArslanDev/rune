import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/circular_progress_indicator_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('CircularProgressIndicatorBuilder', () {
    const b = CircularProgressIndicatorBuilder();

    test('typeName is "CircularProgressIndicator"', () {
      expect(b.typeName, 'CircularProgressIndicator');
    });

    test('no args renders indeterminate (value null)', () {
      final w = b.build(
        ResolvedArguments.empty,
        testContext(),
      ) as CircularProgressIndicator;
      expect(w.value, isNull);
      expect(w.strokeWidth, 4.0);
    });

    test('value: 0.5 renders determinate', () {
      final w = b.build(
        const ResolvedArguments(named: {'value': 0.5}),
        testContext(),
      ) as CircularProgressIndicator;
      expect(w.value, 0.5);
    });

    test('color/backgroundColor/strokeWidth plumb through', () {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'color': Color(0xFF00AA00),
            'backgroundColor': Color(0xFFCCCCCC),
            'strokeWidth': 6,
          },
        ),
        testContext(),
      ) as CircularProgressIndicator;
      expect(w.color, const Color(0xFF00AA00));
      expect(w.backgroundColor, const Color(0xFFCCCCCC));
      expect(w.strokeWidth, 6.0);
    });
  });
}

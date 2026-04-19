import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/linear_progress_indicator_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('LinearProgressIndicatorBuilder', () {
    const b = LinearProgressIndicatorBuilder();

    test('typeName is "LinearProgressIndicator"', () {
      expect(b.typeName, 'LinearProgressIndicator');
    });

    test('no args renders indeterminate (value null)', () {
      final w = b.build(
        ResolvedArguments.empty,
        testContext(),
      ) as LinearProgressIndicator;
      expect(w.value, isNull);
    });

    test('value: 0.75 renders determinate', () {
      final w = b.build(
        const ResolvedArguments(named: {'value': 0.75}),
        testContext(),
      ) as LinearProgressIndicator;
      expect(w.value, 0.75);
    });

    test('color/backgroundColor/minHeight plumb through', () {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'color': Color(0xFF0000FF),
            'backgroundColor': Color(0xFFDDDDDD),
            'minHeight': 8,
          },
        ),
        testContext(),
      ) as LinearProgressIndicator;
      expect(w.color, const Color(0xFF0000FF));
      expect(w.backgroundColor, const Color(0xFFDDDDDD));
      expect(w.minHeight, 8.0);
    });
  });
}

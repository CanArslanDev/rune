import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/sized_box_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('SizedBoxBuilder', () {
    const b = SizedBoxBuilder();

    test('typeName is "SizedBox"', () {
      expect(b.typeName, 'SizedBox');
    });

    test('builds empty SizedBox when no args', () {
      final w = b.build(ResolvedArguments.empty, testContext()) as SizedBox;
      expect(w.width, isNull);
      expect(w.height, isNull);
      expect(w.child, isNull);
    });

    test('applies width and height (num → double)', () {
      final w = b.build(
        const ResolvedArguments(named: {'width': 10, 'height': 20.5}),
        testContext(),
      ) as SizedBox;
      expect(w.width, 10.0);
      expect(w.height, 20.5);
    });

    test('accepts child widget', () {
      const child = Text('hi');
      final w = b.build(
        const ResolvedArguments(named: {'child': child}),
        testContext(),
      ) as SizedBox;
      expect(w.child, same(child));
    });
  });
}

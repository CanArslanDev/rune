import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/center_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('CenterBuilder', () {
    const b = CenterBuilder();

    test('typeName is "Center"', () {
      expect(b.typeName, 'Center');
    });

    test('bare Center with no args', () {
      final w = b.build(const ResolvedArguments(), testContext()) as Center;
      expect(w.child, isNull);
      expect(w.heightFactor, isNull);
      expect(w.widthFactor, isNull);
    });

    test('applies heightFactor and widthFactor', () {
      final w = b.build(
        const ResolvedArguments(named: {'heightFactor': 0.5, 'widthFactor': 2}),
        testContext(),
      ) as Center;
      expect(w.heightFactor, 0.5);
      expect(w.widthFactor, 2.0);
    });

    test('accepts child widget', () {
      const child = Text('x');
      final w = b.build(
        const ResolvedArguments(named: {'child': child}),
        testContext(),
      ) as Center;
      expect(w.child, same(child));
    });
  });
}

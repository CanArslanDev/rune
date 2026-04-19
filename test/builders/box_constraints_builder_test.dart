import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/box_constraints_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('BoxConstraintsBuilder', () {
    const b = BoxConstraintsBuilder();

    test('typeName/constructorName', () {
      expect(b.typeName, 'BoxConstraints');
      expect(b.constructorName, isNull);
    });

    test('no args builds the unconstrained default', () {
      final c = b.build(ResolvedArguments.empty, testContext());
      expect(c.minWidth, 0.0);
      expect(c.maxWidth, double.infinity);
      expect(c.minHeight, 0.0);
      expect(c.maxHeight, double.infinity);
    });

    test('all four edges plumb through', () {
      final c = b.build(
        const ResolvedArguments(
          named: {
            'minWidth': 10,
            'maxWidth': 200,
            'minHeight': 20,
            'maxHeight': 300,
          },
        ),
        testContext(),
      );
      expect(c.minWidth, 10.0);
      expect(c.maxWidth, 200.0);
      expect(c.minHeight, 20.0);
      expect(c.maxHeight, 300.0);
    });

    test('partial args keep defaults for the rest', () {
      final c = b.build(
        const ResolvedArguments(named: {'maxWidth': 200}),
        testContext(),
      );
      expect(c.minWidth, 0.0);
      expect(c.maxWidth, 200.0);
      expect(c.minHeight, 0.0);
      expect(c.maxHeight, double.infinity);
    });
  });
}

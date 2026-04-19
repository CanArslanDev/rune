import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/constrained_box_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('ConstrainedBoxBuilder', () {
    const b = ConstrainedBoxBuilder();

    test('typeName is "ConstrainedBox"', () {
      expect(b.typeName, 'ConstrainedBox');
    });

    test('constraints + child plumb through', () {
      const child = Text('x');
      const constraints =
          BoxConstraints(minWidth: 100, maxWidth: 200);
      final w = b.build(
        const ResolvedArguments(
          named: {
            'constraints': constraints,
            'child': child,
          },
        ),
        testContext(),
      ) as ConstrainedBox;
      expect(w.constraints, constraints);
      expect(w.child, same(child));
    });

    test('missing constraints throws ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}

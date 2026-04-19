import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/fractionally_sized_box_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('FractionallySizedBoxBuilder', () {
    const b = FractionallySizedBoxBuilder();

    test('typeName is "FractionallySizedBox"', () {
      expect(b.typeName, 'FractionallySizedBox');
    });

    test('widthFactor, heightFactor, and child plumb through', () {
      const child = Text('x');
      final w = b.build(
        const ResolvedArguments(
          named: {
            'widthFactor': 0.5,
            'heightFactor': 0.75,
            'child': child,
          },
        ),
        testContext(),
      ) as FractionallySizedBox;
      expect(w.widthFactor, 0.5);
      expect(w.heightFactor, 0.75);
      expect(w.child, same(child));
      expect(w.alignment, Alignment.center);
    });

    test('no args leaves factors null and alignment centered', () {
      final w = b.build(ResolvedArguments.empty, testContext())
          as FractionallySizedBox;
      expect(w.widthFactor, isNull);
      expect(w.heightFactor, isNull);
      expect(w.alignment, Alignment.center);
      expect(w.child, isNull);
    });
  });
}

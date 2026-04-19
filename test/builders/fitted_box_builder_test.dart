import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/fitted_box_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('FittedBoxBuilder', () {
    const b = FittedBoxBuilder();

    test('typeName is "FittedBox"', () {
      expect(b.typeName, 'FittedBox');
    });

    test('fit + child plumb through', () {
      const child = Text('x');
      final w = b.build(
        const ResolvedArguments(
          named: {'fit': BoxFit.cover, 'child': child},
        ),
        testContext(),
      ) as FittedBox;
      expect(w.fit, BoxFit.cover);
      expect(w.child, same(child));
      expect(w.alignment, Alignment.center);
    });

    test('alignment plumbs through', () {
      final w = b.build(
        const ResolvedArguments(
          named: {'alignment': Alignment.topLeft},
        ),
        testContext(),
      ) as FittedBox;
      expect(w.alignment, Alignment.topLeft);
      // fit default is contain.
      expect(w.fit, BoxFit.contain);
    });
  });
}

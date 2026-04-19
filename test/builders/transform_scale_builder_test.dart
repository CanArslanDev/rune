import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/transform_scale_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('TransformScaleBuilder', () {
    const b = TransformScaleBuilder();

    test('typeName/constructorName', () {
      expect(b.typeName, 'Transform');
      expect(b.constructorName, 'scale');
    });

    test('uniform scale + child plumbs through', () {
      const child = Text('x');
      final w = b.build(
        const ResolvedArguments(
          named: {'scale': 2.0, 'child': child},
        ),
        testContext(),
      ) as Transform;
      expect(w.child, same(child));
      // Scale of 2.0 on diagonal.
      expect(w.transform.getColumn(0).x, 2.0);
      expect(w.transform.getColumn(1).y, 2.0);
    });

    test('scaleX + scaleY plumb through', () {
      final w = b.build(
        const ResolvedArguments(
          named: {'scaleX': 2, 'scaleY': 0.5},
        ),
        testContext(),
      ) as Transform;
      expect(w.transform.getColumn(0).x, 2.0);
      expect(w.transform.getColumn(1).y, 0.5);
    });

    test('alignment plumbs through', () {
      final w = b.build(
        const ResolvedArguments(
          named: {'scale': 1.5, 'alignment': Alignment.topLeft},
        ),
        testContext(),
      ) as Transform;
      expect(w.alignment, Alignment.topLeft);
    });
  });
}

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/transform_flip_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('TransformFlipBuilder', () {
    const b = TransformFlipBuilder();

    test('typeName/constructorName', () {
      expect(b.typeName, 'Transform');
      expect(b.constructorName, 'flip');
    });

    test('flipX: true, child plumbs through', () {
      const child = Text('x');
      final w = b.build(
        const ResolvedArguments(
          named: {'flipX': true, 'child': child},
        ),
        testContext(),
      ) as Transform;
      expect(w.child, same(child));
      // Flipping X negates the x-scale on the diagonal.
      expect(w.transform.getColumn(0).x, -1.0);
      expect(w.transform.getColumn(1).y, 1.0);
    });

    test('flipX: true, flipY: true plumbs through', () {
      final w = b.build(
        const ResolvedArguments(
          named: {'flipX': true, 'flipY': true},
        ),
        testContext(),
      ) as Transform;
      expect(w.transform.getColumn(0).x, -1.0);
      expect(w.transform.getColumn(1).y, -1.0);
    });

    test('no args renders an identity flip', () {
      final w = b.build(
        ResolvedArguments.empty,
        testContext(),
      ) as Transform;
      expect(w.transform.getColumn(0).x, 1.0);
      expect(w.transform.getColumn(1).y, 1.0);
    });
  });
}

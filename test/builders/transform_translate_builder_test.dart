import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/transform_translate_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('TransformTranslateBuilder', () {
    const b = TransformTranslateBuilder();

    test('typeName/constructorName', () {
      expect(b.typeName, 'Transform');
      expect(b.constructorName, 'translate');
    });

    test('offset + child plumbs through', () {
      const child = Text('x');
      final w = b.build(
        const ResolvedArguments(
          named: {'offset': Offset(8, 4), 'child': child},
        ),
        testContext(),
      ) as Transform;
      expect(w.child, same(child));
      // Translation lives in the last column of the 4x4 matrix.
      expect(w.transform.getColumn(3).x, 8.0);
      expect(w.transform.getColumn(3).y, 4.0);
    });

    test('missing offset throws ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}

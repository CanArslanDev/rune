import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/transform_rotate_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('TransformRotateBuilder', () {
    const b = TransformRotateBuilder();

    test('typeName/constructorName', () {
      expect(b.typeName, 'Transform');
      expect(b.constructorName, 'rotate');
    });

    test('angle + child plumbs through', () {
      const child = Text('x');
      final w = b.build(
        const ResolvedArguments(
          named: {'angle': 0.5, 'child': child},
        ),
        testContext(),
      ) as Transform;
      expect(w.child, same(child));
      // Alignment defaults to center.
      expect(w.alignment, Alignment.center);
    });

    test('missing angle throws ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}

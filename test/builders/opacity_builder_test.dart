import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/opacity_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('OpacityBuilder', () {
    const b = OpacityBuilder();

    test('typeName is "Opacity"', () {
      expect(b.typeName, 'Opacity');
    });

    test('opacity + child plumb through', () {
      const child = Text('x');
      final w = b.build(
        const ResolvedArguments(
          named: {'opacity': 0.5, 'child': child},
        ),
        testContext(),
      ) as Opacity;
      expect(w.opacity, 0.5);
      expect(w.child, same(child));
      expect(w.alwaysIncludeSemantics, isFalse);
    });

    test('missing opacity throws ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}

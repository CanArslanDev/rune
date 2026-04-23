import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/positioned_fill_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('PositionedFillBuilder', () {
    const b = PositionedFillBuilder();

    test('typeName/constructorName', () {
      expect(b.typeName, 'Positioned');
      expect(b.constructorName, 'fill');
    });

    test('wraps child in Positioned.fill with all sides null', () {
      final result = b.build(
        const ResolvedArguments(named: {'child': SizedBox.shrink()}),
        testContext(),
      );
      expect(result, isA<Positioned>());
      final positioned = result;
      expect(positioned.left, 0);
      expect(positioned.top, 0);
      expect(positioned.right, 0);
      expect(positioned.bottom, 0);
      expect(positioned.child, isA<SizedBox>());
    });

    test('overrides are forwarded when provided', () {
      final result = b.build(
        const ResolvedArguments(
          named: {
            'child': SizedBox.shrink(),
            'left': 5,
            'top': 10,
          },
        ),
        testContext(),
      );
      expect(result, isA<Positioned>());
      final positioned = result;
      expect(positioned.left, 5);
      expect(positioned.top, 10);
      expect(positioned.right, 0);
      expect(positioned.bottom, 0);
    });

    test('missing child throws ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/padding_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('PaddingBuilder', () {
    const b = PaddingBuilder();

    test('typeName is "Padding"', () {
      expect(b.typeName, 'Padding');
    });

    test('applies EdgeInsets padding + child', () {
      const child = Text('x');
      final w = b.build(
        const ResolvedArguments(
          named: {'padding': EdgeInsets.all(8), 'child': child},
        ),
        testContext(),
      ) as Padding;
      expect(w.padding, const EdgeInsets.all(8));
      expect(w.child, same(child));
    });

    test('child may be omitted', () {
      final w = b.build(
        const ResolvedArguments(named: {'padding': EdgeInsets.all(4)}),
        testContext(),
      ) as Padding;
      expect(w.child, isNull);
    });

    test('missing padding throws ArgumentException', () {
      expect(
        () => b.build(const ResolvedArguments(), testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}

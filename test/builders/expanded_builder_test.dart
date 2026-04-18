import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/expanded_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('ExpandedBuilder', () {
    const b = ExpandedBuilder();

    test('typeName is "Expanded"', () {
      expect(b.typeName, 'Expanded');
    });

    test('defaults flex to 1', () {
      const child = Text('x');
      final w = b.build(
        const ResolvedArguments(named: {'child': child}),
        testContext(),
      ) as Expanded;
      expect(w.flex, 1);
      expect(w.child, same(child));
    });

    test('applies explicit flex', () {
      const child = Text('x');
      final w = b.build(
        const ResolvedArguments(named: {'flex': 3, 'child': child}),
        testContext(),
      ) as Expanded;
      expect(w.flex, 3);
    });

    test('missing child throws ArgumentException', () {
      expect(
        () => b.build(const ResolvedArguments(), testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}

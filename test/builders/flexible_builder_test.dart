import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/flexible_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('FlexibleBuilder', () {
    const b = FlexibleBuilder();

    test('typeName is "Flexible"', () {
      expect(b.typeName, 'Flexible');
    });

    test('defaults flex=1 and fit=loose', () {
      const child = Text('x');
      final w = b.build(
        const ResolvedArguments(named: {'child': child}),
        testContext(),
      ) as Flexible;
      expect(w.flex, 1);
      expect(w.fit, FlexFit.loose);
    });

    test('applies explicit flex + fit', () {
      const child = Text('x');
      final w = b.build(
        const ResolvedArguments(
          named: {'flex': 2, 'fit': FlexFit.tight, 'child': child},
        ),
        testContext(),
      ) as Flexible;
      expect(w.flex, 2);
      expect(w.fit, FlexFit.tight);
    });

    test('missing child throws ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}

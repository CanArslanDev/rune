import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/card_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('CardBuilder', () {
    const b = CardBuilder();

    test('typeName is "Card"', () {
      expect(b.typeName, 'Card');
    });

    test('bare Card with no args', () {
      final w = b.build(const ResolvedArguments(), testContext());
      expect(w, isA<Card>());
    });

    test('applies elevation + color + margin + child', () {
      const child = Text('x');
      final w = b.build(
        const ResolvedArguments(
          named: {
            'elevation': 4,
            'color': Color(0xFFABCDEF),
            'margin': EdgeInsets.all(8),
            'child': child,
          },
        ),
        testContext(),
      ) as Card;
      expect(w.elevation, 4.0);
      expect(w.color, const Color(0xFFABCDEF));
      expect(w.margin, const EdgeInsets.all(8));
      expect(w.child, same(child));
    });
  });
}

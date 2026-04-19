import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/colored_box_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('ColoredBoxBuilder', () {
    const b = ColoredBoxBuilder();

    test('typeName is "ColoredBox"', () {
      expect(b.typeName, 'ColoredBox');
    });

    test('color + child plumb through', () {
      const child = Text('x');
      final w = b.build(
        const ResolvedArguments(
          named: {'color': Color(0xFFFF0000), 'child': child},
        ),
        testContext(),
      ) as ColoredBox;
      expect(w.color, const Color(0xFFFF0000));
      expect(w.child, same(child));
    });

    test('missing color throws ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}

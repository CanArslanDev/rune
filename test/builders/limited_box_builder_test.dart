import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/limited_box_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('LimitedBoxBuilder', () {
    const b = LimitedBoxBuilder();

    test('typeName is "LimitedBox"', () {
      expect(b.typeName, 'LimitedBox');
    });

    test('maxWidth, maxHeight, and child plumb through', () {
      const child = Text('x');
      final w = b.build(
        const ResolvedArguments(
          named: {
            'maxWidth': 200,
            'maxHeight': 100,
            'child': child,
          },
        ),
        testContext(),
      ) as LimitedBox;
      expect(w.maxWidth, 200.0);
      expect(w.maxHeight, 100.0);
      expect(w.child, same(child));
    });

    test('no args defaults both edges to infinity', () {
      final w = b.build(ResolvedArguments.empty, testContext())
          as LimitedBox;
      expect(w.maxWidth, double.infinity);
      expect(w.maxHeight, double.infinity);
      expect(w.child, isNull);
    });
  });
}

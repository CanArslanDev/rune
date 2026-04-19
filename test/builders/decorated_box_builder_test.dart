import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/decorated_box_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('DecoratedBoxBuilder', () {
    const b = DecoratedBoxBuilder();

    test('typeName is "DecoratedBox"', () {
      expect(b.typeName, 'DecoratedBox');
    });

    test('decoration + child plumb through with default position', () {
      const child = Text('x');
      const decoration = BoxDecoration(color: Color(0xFF00FF00));
      final w = b.build(
        const ResolvedArguments(
          named: {'decoration': decoration, 'child': child},
        ),
        testContext(),
      ) as DecoratedBox;
      expect(w.decoration, decoration);
      expect(w.child, same(child));
      expect(w.position, DecorationPosition.background);
    });

    test('missing decoration throws ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('position: foreground plumbs through', () {
      const decoration = BoxDecoration(color: Color(0xFF00FF00));
      final w = b.build(
        const ResolvedArguments(
          named: {
            'decoration': decoration,
            'position': DecorationPosition.foreground,
          },
        ),
        testContext(),
      ) as DecoratedBox;
      expect(w.position, DecorationPosition.foreground);
    });
  });
}

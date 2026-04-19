import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/safe_area_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('SafeAreaBuilder', () {
    const b = SafeAreaBuilder();

    test('typeName is "SafeArea"', () {
      expect(b.typeName, 'SafeArea');
    });

    test('child plumbs through with default edges', () {
      const child = Text('x');
      final w = b.build(
        const ResolvedArguments(named: {'child': child}),
        testContext(),
      ) as SafeArea;
      expect(w.child, same(child));
      expect(w.left, isTrue);
      expect(w.top, isTrue);
      expect(w.right, isTrue);
      expect(w.bottom, isTrue);
      expect(w.minimum, EdgeInsets.zero);
      expect(w.maintainBottomViewPadding, isFalse);
    });

    test('missing child throws ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('custom edges + minimum + maintainBottomViewPadding plumb through',
        () {
      const child = Text('x');
      final w = b.build(
        const ResolvedArguments(
          named: {
            'left': false,
            'top': false,
            'right': true,
            'bottom': true,
            'minimum': EdgeInsets.all(4),
            'maintainBottomViewPadding': true,
            'child': child,
          },
        ),
        testContext(),
      ) as SafeArea;
      expect(w.left, isFalse);
      expect(w.top, isFalse);
      expect(w.right, isTrue);
      expect(w.bottom, isTrue);
      expect(w.minimum, const EdgeInsets.all(4));
      expect(w.maintainBottomViewPadding, isTrue);
      expect(w.child, same(child));
    });
  });
}

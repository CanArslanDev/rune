import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/sliver_fill_remaining_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('SliverFillRemainingBuilder', () {
    const b = SliverFillRemainingBuilder();

    test('typeName is "SliverFillRemaining"', () {
      expect(b.typeName, 'SliverFillRemaining');
    });

    test('child + hasScrollBody plumb through', () {
      const child = Center(child: Text('x'));
      final w = b.build(
        const ResolvedArguments(
          named: {
            'child': child,
            'hasScrollBody': false,
          },
        ),
        testContext(),
      ) as SliverFillRemaining;
      expect(w.child, same(child));
      expect(w.hasScrollBody, isFalse);
      expect(w.fillOverscroll, isFalse);
    });

    test('default flags match Flutter defaults', () {
      final w = b.build(ResolvedArguments.empty, testContext())
          as SliverFillRemaining;
      expect(w.hasScrollBody, isTrue);
      expect(w.fillOverscroll, isFalse);
      expect(w.child, isNull);
    });
  });
}

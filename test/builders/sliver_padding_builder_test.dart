import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/sliver_padding_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('SliverPaddingBuilder', () {
    const b = SliverPaddingBuilder();

    test('typeName is "SliverPadding"', () {
      expect(b.typeName, 'SliverPadding');
    });

    test('padding + sliver plumb through', () {
      const sliver = SliverToBoxAdapter(child: Text('x'));
      final w = b.build(
        const ResolvedArguments(
          named: {
            'padding': EdgeInsets.all(16),
            'sliver': sliver,
          },
        ),
        testContext(),
      ) as SliverPadding;
      expect(w.padding, const EdgeInsets.all(16));
      expect(w.child, same(sliver));
    });

    test('missing padding throws ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}

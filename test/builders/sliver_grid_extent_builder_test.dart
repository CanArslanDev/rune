import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/sliver_grid_extent_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('SliverGridExtentBuilder', () {
    const b = SliverGridExtentBuilder();

    test('typeName + constructorName', () {
      expect(b.typeName, 'SliverGrid');
      expect(b.constructorName, 'extent');
    });

    test('renders with maxCrossAxisExtent + children', () {
      const a = Text('a');
      const c = Text('b');
      final w = b.build(
        const ResolvedArguments(
          named: {
            'maxCrossAxisExtent': 150.0,
            'children': <Object?>[a, c],
            'mainAxisSpacing': 4,
            'crossAxisSpacing': 8,
            'childAspectRatio': 1.5,
          },
        ),
        testContext(),
      );
      expect(w, isA<SliverGrid>());
    });

    test('missing maxCrossAxisExtent throws ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}

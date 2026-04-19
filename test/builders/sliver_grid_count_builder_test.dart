import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/sliver_grid_count_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('SliverGridCountBuilder', () {
    const b = SliverGridCountBuilder();

    test('typeName + constructorName', () {
      expect(b.typeName, 'SliverGrid');
      expect(b.constructorName, 'count');
    });

    test('renders with crossAxisCount + children', () {
      const a = Text('a');
      const c = Text('b');
      final w = b.build(
        const ResolvedArguments(
          named: {
            'crossAxisCount': 2,
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

    test('missing crossAxisCount throws ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}

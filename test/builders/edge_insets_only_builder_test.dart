import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/edge_insets_only_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('EdgeInsetsOnlyBuilder', () {
    const b = EdgeInsetsOnlyBuilder();

    test('typeName/constructorName', () {
      expect(b.typeName, 'EdgeInsets');
      expect(b.constructorName, 'only');
    });

    test('builds with all four sides', () {
      final result = b.build(
        const ResolvedArguments(
          named: {'left': 1, 'top': 2, 'right': 3, 'bottom': 4},
        ),
        testContext(),
      );
      expect(
        result,
        const EdgeInsets.only(left: 1, top: 2, right: 3, bottom: 4),
      );
    });

    test('sparse subset of sides', () {
      final result = b.build(
        const ResolvedArguments(named: {'left': 8, 'bottom': 4}),
        testContext(),
      );
      expect(result, const EdgeInsets.only(left: 8, bottom: 4));
    });

    test('no args produces zero insets', () {
      final result = b.build(const ResolvedArguments(), testContext());
      expect(result, EdgeInsets.zero);
    });

    test('accepts mixed int and double', () {
      final result = b.build(
        const ResolvedArguments(named: {'left': 1, 'top': 2.5}),
        testContext(),
      );
      expect(result, const EdgeInsets.only(left: 1, top: 2.5));
    });
  });
}

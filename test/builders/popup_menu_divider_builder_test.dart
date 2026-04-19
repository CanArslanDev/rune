import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/popup_menu_divider_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('PopupMenuDividerBuilder', () {
    const b = PopupMenuDividerBuilder();

    test('typeName is "PopupMenuDivider"', () {
      expect(b.typeName, 'PopupMenuDivider');
    });

    test('default height is 16', () {
      final w = b.build(ResolvedArguments.empty, testContext())
          as PopupMenuDivider;
      expect(w.height, 16.0);
    });

    test('height plumbs through (int coerced to double)', () {
      final w = b.build(
        const ResolvedArguments(named: {'height': 24}),
        testContext(),
      ) as PopupMenuDivider;
      expect(w.height, 24.0);
    });

    test('height plumbs through (double)', () {
      final w = b.build(
        const ResolvedArguments(named: {'height': 8.5}),
        testContext(),
      ) as PopupMenuDivider;
      expect(w.height, 8.5);
    });

    test('no-args renders a PopupMenuDivider', () {
      final w = b.build(ResolvedArguments.empty, testContext());
      expect(w, isA<PopupMenuDivider>());
    });
  });
}

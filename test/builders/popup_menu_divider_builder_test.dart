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

    test('height plumbs through', () {
      final w = b.build(
        const ResolvedArguments(named: {'height': 24}),
        testContext(),
      ) as PopupMenuDivider;
      expect(w.height, 24.0);
    });

    test('thickness, indent, endIndent, color plumb through', () {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'thickness': 2,
            'indent': 8,
            'endIndent': 12,
            'color': Color(0xFFABCDEF),
          },
        ),
        testContext(),
      ) as PopupMenuDivider;
      expect(w.thickness, 2.0);
      expect(w.indent, 8.0);
      expect(w.endIndent, 12.0);
      expect(w.color, const Color(0xFFABCDEF));
    });

    test('no-args renders without throwing', () {
      final w = b.build(ResolvedArguments.empty, testContext())
          as PopupMenuDivider;
      expect(w.color, isNull);
    });
  });
}

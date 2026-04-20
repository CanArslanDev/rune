import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/checked_popup_menu_item_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('CheckedPopupMenuItemBuilder', () {
    const b = CheckedPopupMenuItemBuilder();

    test('typeName is "CheckedPopupMenuItem"', () {
      expect(b.typeName, 'CheckedPopupMenuItem');
    });

    test('missing value key raises ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(named: {'child': Text('x')}),
          testContext(),
        ),
        throwsA(
          isA<ArgumentException>().having(
            (e) => e.message,
            'message',
            contains('"value"'),
          ),
        ),
      );
    });

    test('missing child raises ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(named: {'value': 1}),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('defaults: checked=false, enabled=true, padding=null', () {
      final w = b.build(
        const ResolvedArguments(
          named: {'value': 'x', 'child': Text('Item')},
        ),
        testContext(),
      ) as CheckedPopupMenuItem<Object?>;
      expect(w.checked, isFalse);
      expect(w.enabled, isTrue);
      expect(w.value, 'x');
      expect(w.padding, isNull);
    });

    test('checked, enabled, padding plumb through', () {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'value': 'x',
            'child': Text('Item'),
            'checked': true,
            'enabled': false,
            'padding': EdgeInsets.all(4),
          },
        ),
        testContext(),
      ) as CheckedPopupMenuItem<Object?>;
      expect(w.checked, isTrue);
      expect(w.enabled, isFalse);
      expect(w.padding, const EdgeInsets.all(4));
    });
  });
}

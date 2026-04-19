import 'package:flutter/material.dart' hide PopupMenuItemBuilder;
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/popup_menu_item_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('PopupMenuItemBuilder', () {
    const b = PopupMenuItemBuilder();

    test('typeName is "PopupMenuItem"', () {
      expect(b.typeName, 'PopupMenuItem');
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

    test('explicit null value is accepted', () {
      final w = b.build(
        const ResolvedArguments(
          named: {'value': null, 'child': Text('noop')},
        ),
        testContext(),
      ) as PopupMenuItem<Object?>;
      expect(w.value, isNull);
    });

    test('value, child, enabled, height plumb through', () {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'value': 'x',
            'child': Text('Item'),
            'enabled': false,
            'height': 56,
          },
        ),
        testContext(),
      ) as PopupMenuItem<Object?>;
      expect(w.value, 'x');
      expect(w.enabled, isFalse);
      expect(w.height, 56.0);
    });

    test('padding plumbs through', () {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'value': 1,
            'child': Text('Item'),
            'padding': EdgeInsets.all(4),
          },
        ),
        testContext(),
      ) as PopupMenuItem<Object?>;
      expect(w.padding, const EdgeInsets.all(4));
    });
  });
}

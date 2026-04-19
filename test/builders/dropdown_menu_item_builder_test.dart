import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/dropdown_menu_item_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('DropdownMenuItemBuilder', () {
    const b = DropdownMenuItemBuilder();

    test('typeName is "DropdownMenuItem"', () {
      expect(b.typeName, 'DropdownMenuItem');
    });

    test('builds DropdownMenuItem<Object?> with value and child', () {
      final w = b.build(
        const ResolvedArguments(
          named: {'value': 1, 'child': Text('One')},
        ),
        testContext(),
      ) as DropdownMenuItem<Object?>;
      expect(w.value, 1);
      expect(w.child, isA<Text>());
      expect(w.enabled, isTrue);
    });

    test('missing value throws ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(named: {'child': Text('One')}),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('explicit value: null does NOT throw', () {
      final w = b.build(
        const ResolvedArguments(
          named: {'value': null, 'child': Text('None')},
        ),
        testContext(),
      ) as DropdownMenuItem<Object?>;
      expect(w.value, isNull);
    });

    test('missing child throws ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(named: {'value': 1}),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('enabled: false plumbs through', () {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'value': 'x',
            'child': Text('X'),
            'enabled': false,
          },
        ),
        testContext(),
      ) as DropdownMenuItem<Object?>;
      expect(w.enabled, isFalse);
    });
  });
}

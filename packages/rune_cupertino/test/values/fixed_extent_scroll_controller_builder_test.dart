import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';
import 'package:rune_cupertino/src/values/fixed_extent_scroll_controller_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('FixedExtentScrollControllerBuilder', () {
    const b = FixedExtentScrollControllerBuilder();

    test('typeName is "FixedExtentScrollController"', () {
      expect(b.typeName, 'FixedExtentScrollController');
    });

    test('constructorName is null (default constructor)', () {
      expect(b.constructorName, isNull);
    });

    test('defaults initialItem to 0 when no args given', () {
      final ctrl = b.build(ResolvedArguments.empty, testContext());
      expect(ctrl, isA<FixedExtentScrollController>());
      expect(ctrl.initialItem, 0);
    });

    test('forwards initialItem when supplied', () {
      final ctrl = b.build(
        const ResolvedArguments(named: {'initialItem': 3}),
        testContext(),
      );
      expect(ctrl.initialItem, 3);
    });

    test('returns a ScrollController subtype', () {
      final ctrl = b.build(ResolvedArguments.empty, testContext());
      expect(ctrl, isA<ScrollController>());
    });
  });
}

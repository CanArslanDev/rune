import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/column_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('ColumnBuilder', () {
    const b = ColumnBuilder();

    test('typeName is "Column"', () {
      expect(b.typeName, 'Column');
    });

    test('builds Column from list of widgets', () {
      const a = Text('a');
      const c = Text('b');
      final w = b.build(
        const ResolvedArguments(named: {
          'children': <Object?>[a, c],
        },),
        testContext(),
      ) as Column;
      expect(w.children, [a, c]);
    });

    test('builds empty Column when no children arg', () {
      final w = b.build(ResolvedArguments.empty, testContext()) as Column;
      expect(w.children, isEmpty);
    });

    test('non-widget entries in children list are filtered out', () {
      const a = Text('a');
      final w = b.build(
        const ResolvedArguments(named: {
          'children': <Object?>[a, 'stringy', null, 42],
        },),
        testContext(),
      ) as Column;
      expect(w.children, [a]);
    });
  });
}

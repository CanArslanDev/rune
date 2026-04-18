import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/row_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('RowBuilder', () {
    const b = RowBuilder();

    test('typeName is "Row"', () {
      expect(b.typeName, 'Row');
    });

    test('builds Row from list of widgets', () {
      const a = Text('a');
      const c = Text('b');
      final w = b.build(
        const ResolvedArguments(named: {
          'children': <Object?>[a, c],
        },),
        testContext(),
      ) as Row;
      expect(w.children, [a, c]);
    });

    test('builds empty Row when no children arg', () {
      final w = b.build(ResolvedArguments.empty, testContext()) as Row;
      expect(w.children, isEmpty);
    });

    test('non-widget entries in children list are filtered out', () {
      const a = Text('a');
      final w = b.build(
        const ResolvedArguments(named: {
          'children': <Object?>[a, 'stringy', null, 42],
        },),
        testContext(),
      ) as Row;
      expect(w.children, [a]);
    });
  });
}

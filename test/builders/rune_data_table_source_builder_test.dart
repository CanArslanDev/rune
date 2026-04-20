import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/rune_data_table_source_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('RuneDataTableSourceBuilder', () {
    const b = RuneDataTableSourceBuilder();

    test('typeName is "RuneDataTableSource"', () {
      expect(b.typeName, 'RuneDataTableSource');
      expect(b.constructorName, isNull);
    });

    test('missing rows raises ArgumentException', () {
      expect(
        () => b.build(
          ResolvedArguments.empty,
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('non-DataRow entry raises ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(
            named: {
              'rows': <Object?>[
                DataRow(cells: [DataCell(Text('ok'))]),
                42,
              ],
            },
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('empty list yields an empty source', () {
      final src = b.build(
        const ResolvedArguments(named: {'rows': <Object?>[]}),
        testContext(),
      );
      expect(src.rowCount, 0);
      expect(src.selectedRowCount, 0);
      expect(src.isRowCountApproximate, isFalse);
      expect(src.getRow(0), isNull);
    });

    test('getRow returns rows by index and null out-of-range', () {
      final src = b.build(
        const ResolvedArguments(
          named: {
            'rows': <Object?>[
              DataRow(cells: [DataCell(Text('A'))]),
              DataRow(cells: [DataCell(Text('B'))]),
            ],
          },
        ),
        testContext(),
      );
      expect(src.rowCount, 2);
      expect(src.getRow(0), isA<DataRow>());
      expect(src.getRow(1), isA<DataRow>());
      expect(src.getRow(2), isNull);
      expect(src.getRow(-1), isNull);
    });
  });
}

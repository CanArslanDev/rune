import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/rune_data_table_source_builder.dart';
import 'package:rune/src/builders/widgets/paginated_data_table_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

DataTableSource _source(List<DataRow> rows) {
  const b = RuneDataTableSourceBuilder();
  return b.build(
    ResolvedArguments(named: <String, Object?>{'rows': rows}),
    testContext(),
  );
}

void main() {
  group('PaginatedDataTableBuilder', () {
    const b = PaginatedDataTableBuilder();

    test('typeName is "PaginatedDataTable"', () {
      expect(b.typeName, 'PaginatedDataTable');
    });

    test('missing columns raises ArgumentException', () {
      expect(
        () => b.build(
          ResolvedArguments(
            named: {'source': _source(const <DataRow>[])},
          ),
          testContext(),
        ),
        throwsA(
          isA<ArgumentException>().having(
            (e) => e.message,
            'message',
            contains('"columns"'),
          ),
        ),
      );
    });

    test('empty columns list raises ArgumentException', () {
      expect(
        () => b.build(
          ResolvedArguments(
            named: {
              'columns': const <Object?>[],
              'source': _source(const <DataRow>[]),
            },
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('missing source raises ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(
            named: <String, Object?>{
              'columns': <Object?>[
                DataColumn(label: Text('A')),
              ],
            },
          ),
          testContext(),
        ),
        throwsA(
          isA<ArgumentException>().having(
            (e) => e.message,
            'message',
            contains('"source"'),
          ),
        ),
      );
    });

    test('non-DataTableSource source raises ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(
            named: <String, Object?>{
              'columns': <Object?>[
                DataColumn(label: Text('A')),
              ],
              'source': 42,
            },
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    testWidgets('renders the header with a DataTableSource', (tester) async {
      final source = _source(const <DataRow>[
        DataRow(cells: [DataCell(Text('Row-0'))]),
        DataRow(cells: [DataCell(Text('Row-1'))]),
      ]);
      final w = b.build(
        ResolvedArguments(
          named: {
            'columns': const <Object?>[
              DataColumn(label: Text('A')),
            ],
            'source': source,
            'rowsPerPage': 5,
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: w)),
        ),
      );
      expect(find.text('A'), findsOneWidget);
      expect(find.text('Row-0'), findsOneWidget);
    });
  });
}

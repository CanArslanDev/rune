import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/data_table_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('DataTableBuilder', () {
    const b = DataTableBuilder();

    test('typeName is "DataTable"', () {
      expect(b.typeName, 'DataTable');
    });

    test('builds with columns and rows, applies defaults', () {
      const col = DataColumn(label: Text('Name'));
      const row = DataRow(cells: [DataCell(Text('alpha'))]);
      final w = b.build(
        const ResolvedArguments(
          named: {
            'columns': <Object?>[col],
            'rows': <Object?>[row],
          },
        ),
        testContext(),
      ) as DataTable;
      expect(w.columns, hasLength(1));
      expect(w.rows, hasLength(1));
      expect(w.sortAscending, isTrue);
      expect(w.showBottomBorder, isFalse);
      expect(w.sortColumnIndex, isNull);
    });

    test('non-DataColumn / non-DataRow entries are filtered', () {
      const col = DataColumn(label: Text('Name'));
      const row = DataRow(cells: [DataCell(Text('a'))]);
      final w = b.build(
        const ResolvedArguments(
          named: {
            'columns': <Object?>[col, 'bogus'],
            'rows': <Object?>[row, 99],
          },
        ),
        testContext(),
      ) as DataTable;
      expect(w.columns, hasLength(1));
      expect(w.rows, hasLength(1));
    });

    test('missing columns raises ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('empty columns list raises ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(named: {'columns': <Object?>[]}),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('optional sizing arguments are forwarded', () {
      const col = DataColumn(label: Text('Name'));
      final w = b.build(
        const ResolvedArguments(
          named: {
            'columns': <Object?>[col],
            'sortColumnIndex': 0,
            'sortAscending': false,
            'columnSpacing': 24.0,
            'headingRowHeight': 48.0,
            'dataRowMinHeight': 40.0,
            'dataRowMaxHeight': 60.0,
            'showBottomBorder': true,
            'dividerThickness': 2.0,
          },
        ),
        testContext(),
      ) as DataTable;
      expect(w.sortColumnIndex, 0);
      expect(w.sortAscending, isFalse);
      expect(w.columnSpacing, 24.0);
      expect(w.headingRowHeight, 48.0);
      expect(w.dataRowMinHeight, 40.0);
      expect(w.dataRowMaxHeight, 60.0);
      expect(w.showBottomBorder, isTrue);
      expect(w.dividerThickness, 2.0);
    });

    testWidgets('renders inside a MaterialApp', (tester) async {
      const col = DataColumn(label: Text('Name'));
      const row = DataRow(cells: [DataCell(Text('alpha'))]);
      final w = b.build(
        const ResolvedArguments(
          named: {
            'columns': <Object?>[col],
            'rows': <Object?>[row],
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: w),
          ),
        ),
      );
      expect(find.byType(DataTable), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('alpha'), findsOneWidget);
    });
  });
}

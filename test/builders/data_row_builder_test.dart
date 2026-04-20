import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/data_row_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('DataRowBuilder', () {
    const b = DataRowBuilder();

    test('typeName and constructorName', () {
      expect(b.typeName, 'DataRow');
      expect(b.constructorName, isNull);
    });

    test('builds with cells list and defaults', () {
      const cell = DataCell(Text('x'));
      final row = b.build(
        const ResolvedArguments(
          named: {
            'cells': <Object?>[cell],
          },
        ),
        testContext(),
      );
      expect(row, isA<DataRow>());
      expect(row.cells, hasLength(1));
      expect(row.selected, isFalse);
      expect(row.onSelectChanged, isNull);
    });

    test('non-DataCell entries are silently filtered', () {
      const cell = DataCell(Text('keep'));
      final row = b.build(
        const ResolvedArguments(
          named: {
            'cells': <Object?>[cell, 'bogus', 42],
          },
        ),
        testContext(),
      );
      expect(row.cells, hasLength(1));
      expect(row.cells.first, same(cell));
    });

    test('missing cells yields an empty row', () {
      final row = b.build(ResolvedArguments.empty, testContext());
      expect(row.cells, isEmpty);
    });

    test('selected is honoured', () {
      final row = b.build(
        const ResolvedArguments(
          named: {
            'cells': <Object?>[DataCell(Text('x'))],
            'selected': true,
          },
        ),
        testContext(),
      );
      expect(row.selected, isTrue);
    });

    test('onSelectChanged event name dispatches with the new bool', () {
      final events = RuneEventDispatcher();
      final captured = <List<Object?>>[];
      events.setCatchAllHandler(
        (n, args) => n == 'rowSelected' ? captured.add(args) : null,
      );
      final row = b.build(
        const ResolvedArguments(
          named: {
            'cells': <Object?>[DataCell(Text('x'))],
            'onSelectChanged': 'rowSelected',
          },
        ),
        testContext(events: events),
      );
      expect(row.onSelectChanged, isNotNull);
      row.onSelectChanged!.call(true);
      row.onSelectChanged!.call(null);
      expect(captured, [
        [true],
        [null],
      ]);
    });
  });
}

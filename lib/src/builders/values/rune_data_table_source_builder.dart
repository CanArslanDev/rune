import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds a minimal [DataTableSource] wrapper around a pre-computed list
/// of [DataRow] values (v1.12.0). The wrapper is consumed by
/// [PaginatedDataTable] which demands a [DataTableSource] rather than a
/// plain `List<DataRow>`.
///
/// Source arguments:
/// - `rows` (required, `List<DataRow>`). Each entry must be a [DataRow];
///   any other runtime type raises [ArgumentException].
///
/// Selection and mutation are intentionally out of scope in v1.12.0:
/// the returned source reports `selectedRowCount == 0`, never approximates
/// its row count, and notifies no listeners. Sources that need mutable
/// state should subclass [DataTableSource] in host code and pass the
/// instance through `RuneView.data`.
final class RuneDataTableSourceBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const RuneDataTableSourceBuilder();

  @override
  String get typeName => 'RuneDataTableSource';

  @override
  String? get constructorName => null;

  @override
  DataTableSource build(ResolvedArguments args, RuneContext ctx) {
    final rowsRaw =
        args.require<List<Object?>>('rows', source: 'RuneDataTableSource');
    final rows = <DataRow>[];
    for (var i = 0; i < rowsRaw.length; i++) {
      final entry = rowsRaw[i];
      if (entry is! DataRow) {
        throw ArgumentException(
          'RuneDataTableSource',
          '`rows[$i]` must be a DataRow; got ${entry.runtimeType}',
        );
      }
      rows.add(entry);
    }
    return _RuneDataTableSource(List<DataRow>.unmodifiable(rows));
  }
}

class _RuneDataTableSource extends DataTableSource {
  _RuneDataTableSource(this._rows);

  final List<DataRow> _rows;

  @override
  DataRow? getRow(int index) {
    if (index < 0 || index >= _rows.length) return null;
    return _rows[index];
  }

  @override
  int get rowCount => _rows.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}

import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [DataTable] — a Material data grid with column headers and
/// rows. Required: `columns` (`List<DataColumn>`), `rows`
/// (`List<DataRow>`). Both lists arrive from the resolver as
/// `List<Object?>` and are filtered by runtime type; non-conforming
/// entries are silently dropped, matching the Column/Row children
/// convention.
///
/// Optional: `sortColumnIndex` (int), `sortAscending` (bool, default
/// `true`), `columnSpacing` (double), `headingRowHeight` (double),
/// `dataRowMinHeight` (double), `dataRowMaxHeight` (double),
/// `showBottomBorder` (bool, default `false`), `dividerThickness`
/// (double).
///
/// Flutter's constructor asserts that `columns` is non-empty; source
/// omitting or emptying `columns` raises [ArgumentException].
final class DataTableBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const DataTableBuilder();

  @override
  String get typeName => 'DataTable';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final columnsRaw = args.get<List<Object?>>('columns');
    if (columnsRaw == null) {
      throw const ArgumentException(
        'DataTable',
        'Missing required argument "columns"',
      );
    }
    final columns =
        columnsRaw.whereType<DataColumn>().toList(growable: false);
    if (columns.isEmpty) {
      throw const ArgumentException(
        'DataTable',
        '`columns` must contain at least one DataColumn',
      );
    }
    final rows = (args.get<List<Object?>>('rows') ?? const <Object?>[])
        .whereType<DataRow>()
        .toList(growable: false);
    return DataTable(
      columns: columns,
      rows: rows,
      sortColumnIndex: args.get<int>('sortColumnIndex'),
      sortAscending: args.getOr<bool>('sortAscending', true),
      columnSpacing: args.get<double>('columnSpacing'),
      headingRowHeight: args.get<double>('headingRowHeight'),
      dataRowMinHeight: args.get<double>('dataRowMinHeight'),
      dataRowMaxHeight: args.get<double>('dataRowMaxHeight'),
      showBottomBorder: args.getOr<bool>('showBottomBorder', false),
      dividerThickness: args.get<double>('dividerThickness'),
    );
  }
}

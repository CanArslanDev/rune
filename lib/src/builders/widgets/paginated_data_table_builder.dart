import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/event_callback.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds Material [PaginatedDataTable] (v1.12.0). Unlike [DataTable]
/// which owns its rows directly, [PaginatedDataTable] consumes a
/// [DataTableSource]; pair with the `RuneDataTableSource(rows: [...])`
/// value builder for static, source-level row lists, or pass a host-
/// provided [DataTableSource] through `RuneView.data` for dynamic data.
///
/// Source arguments:
/// - `columns` (required, `List<DataColumn>`).
/// - `source` (required, [DataTableSource]).
/// - `header` ([Widget]?). Shown above the table; required for `actions`.
/// - `actions` (`List<Widget>`?). Icon buttons shown in the header.
/// - `rowsPerPage` ([int]?). Defaults to
///   `PaginatedDataTable.defaultRowsPerPage` (10).
/// - `availableRowsPerPage` (`List<int>`?). Page-size picker entries.
/// - `onPageChanged` (`String` event name or `RuneClosure` of arity 1).
///   Receives the new first-row index as its sole argument.
/// - `onRowsPerPageChanged` (`String` event name or `RuneClosure` of
///   arity 1). Receives the new rows-per-page value.
/// - `sortColumnIndex` ([int]?).
/// - `sortAscending` ([bool]?). Defaults to `true`.
final class PaginatedDataTableBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const PaginatedDataTableBuilder();

  @override
  String get typeName => 'PaginatedDataTable';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final columnsRaw = args.get<List<Object?>>('columns');
    if (columnsRaw == null) {
      throw const ArgumentException(
        'PaginatedDataTable',
        'Missing required argument "columns"',
      );
    }
    final columns =
        columnsRaw.whereType<DataColumn>().toList(growable: false);
    if (columns.isEmpty) {
      throw const ArgumentException(
        'PaginatedDataTable',
        '`columns` must contain at least one DataColumn',
      );
    }
    final source = args.named['source'];
    if (source == null) {
      throw const ArgumentException(
        'PaginatedDataTable',
        'Missing required argument "source"',
      );
    }
    if (source is! DataTableSource) {
      throw ArgumentException(
        'PaginatedDataTable',
        '`source` must be a DataTableSource (e.g. RuneDataTableSource); '
        'got ${source.runtimeType}',
      );
    }
    final availableRowsPerPageRaw =
        args.get<List<Object?>>('availableRowsPerPage');
    final availableRowsPerPage = availableRowsPerPageRaw
        ?.whereType<int>()
        .toList(growable: false);
    final actionsRaw = args.get<List<Object?>>('actions');
    final actions = actionsRaw?.whereType<Widget>().toList(growable: false);
    return PaginatedDataTable(
      columns: columns,
      source: source,
      header: args.get<Widget>('header'),
      actions: actions,
      rowsPerPage: args.getOr<int>(
        'rowsPerPage',
        PaginatedDataTable.defaultRowsPerPage,
      ),
      availableRowsPerPage:
          availableRowsPerPage ?? const <int>[10, 25, 50, 100],
      onPageChanged:
          valueEventCallback<int>(args.named['onPageChanged'], ctx.events),
      onRowsPerPageChanged: valueEventCallback<int?>(
        args.named['onRowsPerPageChanged'],
        ctx.events,
      ),
      sortColumnIndex: args.get<int>('sortColumnIndex'),
      sortAscending: args.getOr<bool>('sortAscending', true),
    );
  }
}

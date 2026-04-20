import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/closure_builder_helpers.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [DataColumn] — the header descriptor for one column of a
/// [DataTable]. Required `label` (Widget); optional `numeric` (bool,
/// default `false`), `tooltip` (String), and `onSort` — a 2-arg
/// closure `(int columnIndex, bool ascending) -> void` invoked when
/// the user taps the column header.
///
/// `onSort` accepts a closure only (no String event-name path):
/// the column index is bound by the table, not the source, so the
/// closure form expresses the intent cleanly. Missing `onSort` leaves
/// the column non-sortable.
final class DataColumnBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const DataColumnBuilder();

  @override
  String get typeName => 'DataColumn';

  @override
  String? get constructorName => null;

  @override
  DataColumn build(ResolvedArguments args, RuneContext ctx) {
    return DataColumn(
      label: args.require<Widget>('label', source: 'DataColumn'),
      numeric: args.getOr<bool>('numeric', false),
      tooltip: args.get<String>('tooltip'),
      onSort: toIntBoolCallback(
        args.named['onSort'],
        'DataColumn',
        paramName: 'onSort',
      ),
    );
  }
}

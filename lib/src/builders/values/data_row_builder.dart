import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/event_callback.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [DataRow] — one row of a [DataTable]. Required `cells`
/// (`List<DataCell>`; non-[DataCell] entries are silently filtered).
/// Optional: `selected` (bool, default `false`); `onSelectChanged`
/// (String event name or `(bool?) -> void` closure — the new selection
/// state is forwarded as the sole argument, or `null` when the user
/// de-selects under a non-selectable row shape); `color`
/// ([WidgetStateProperty] of [Color], most commonly produced by a
/// `WidgetStateProperty.all(...)` call — a value builder wrapping that
/// API can be added later; for now source passes a pre-resolved
/// property via a data binding).
final class DataRowBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const DataRowBuilder();

  @override
  String get typeName => 'DataRow';

  @override
  String? get constructorName => null;

  @override
  DataRow build(ResolvedArguments args, RuneContext ctx) {
    final cells = (args.get<List<Object?>>('cells') ?? const <Object?>[])
        .whereType<DataCell>()
        .toList(growable: false);
    return DataRow(
      cells: cells,
      selected: args.getOr<bool>('selected', false),
      onSelectChanged: valueEventCallback<bool?>(
        args.named['onSelectChanged'],
        ctx.events,
      ),
      color: args.get<WidgetStateProperty<Color?>>('color'),
    );
  }
}

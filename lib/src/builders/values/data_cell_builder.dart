import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/event_callback.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [DataCell] — one cell in a [DataRow]. Positional `child`
/// (Widget) is required; optional `onTap` (String event name or
/// closure), `showEditIcon` (bool, default `false`), and `placeholder`
/// (bool, default `false`).
///
/// Flutter's constructor takes `child` as its positional argument;
/// Rune source can spell it either way:
///
/// ```
/// DataCell(Text('alpha'))
/// DataCell(child: Text('alpha'), onTap: 'cellTapped')
/// ```
///
/// A named `child` wins over the positional one when both are given.
final class DataCellBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const DataCellBuilder();

  @override
  String get typeName => 'DataCell';

  @override
  String? get constructorName => null;

  @override
  DataCell build(ResolvedArguments args, RuneContext ctx) {
    final named = args.get<Widget>('child');
    final child = named ??
        args.requirePositional<Widget>(0, source: 'DataCell');
    return DataCell(
      child,
      onTap: voidEventCallback(args.named['onTap'], ctx.events),
      showEditIcon: args.getOr<bool>('showEditIcon', false),
      placeholder: args.getOr<bool>('placeholder', false),
    );
  }
}

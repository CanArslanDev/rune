import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds Material [PopupMenuDivider], a horizontal separator entry for a
/// [PopupMenuButton]'s `itemBuilder` return list.
///
/// Supported named arguments:
/// - `height` ([num]? coerced to double). Defaults to 16 logical pixels
///   (Flutter's own default). Other `Divider`-style slots
///   (`thickness`, `indent`, `endIndent`, `color`) were added to
///   Flutter's `PopupMenuDivider` in a later release and are therefore
///   deferred; the CI-pinned Flutter (3.24) does not accept them.
final class PopupMenuDividerBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const PopupMenuDividerBuilder();

  @override
  String get typeName => 'PopupMenuDivider';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return PopupMenuDivider(
      height: args.get<num>('height')?.toDouble() ?? 16.0,
    );
  }
}

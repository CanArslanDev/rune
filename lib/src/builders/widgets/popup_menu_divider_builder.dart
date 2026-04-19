import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds Material [PopupMenuDivider] - a horizontal separator entry for
/// a [PopupMenuButton]'s `itemBuilder` return list.
///
/// Supported named arguments:
/// - `height` ([num]? coerced to double). Defaults to 16 logical pixels
///   (Flutter's own default).
/// - `thickness` ([num]? coerced to double).
/// - `indent` ([num]? coerced to double).
/// - `endIndent` ([num]? coerced to double).
/// - `color` ([Color]?).
final class PopupMenuDividerBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const PopupMenuDividerBuilder();

  @override
  String get typeName => 'PopupMenuDivider';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return PopupMenuDivider(
      height: args.get<num>('height')?.toDouble() ?? 16.0,
      thickness: args.get<num>('thickness')?.toDouble(),
      indent: args.get<num>('indent')?.toDouble(),
      endIndent: args.get<num>('endIndent')?.toDouble(),
      color: args.get<Color>('color'),
    );
  }
}

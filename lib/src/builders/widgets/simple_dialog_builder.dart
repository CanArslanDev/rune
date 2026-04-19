import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds Material [SimpleDialog] - a modal surface holding a vertical
/// list of option widgets (typically [SimpleDialogOption]s). Shown via
/// the imperative `showDialog(...)` bridge.
///
/// Supported named arguments:
/// - `title` ([Widget]?) - optional heading widget.
/// - `children` (`List<Widget>?`) - the option list. Non-[Widget]
///   entries are silently dropped.
/// - `backgroundColor` ([Color]?).
/// - `elevation` ([num]? coerced to double).
/// - `titlePadding` ([EdgeInsetsGeometry]?).
/// - `contentPadding` ([EdgeInsetsGeometry]?).
/// - `insetPadding` ([EdgeInsets]?). When omitted, falls back to
///   Flutter's default inset spacing.
final class SimpleDialogBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const SimpleDialogBuilder();

  @override
  String get typeName => 'SimpleDialog';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final rawChildren = args.get<List<Object?>>('children');
    final children = rawChildren?.whereType<Widget>().toList(growable: false);
    return SimpleDialog(
      title: args.get<Widget>('title'),
      backgroundColor: args.get<Color>('backgroundColor'),
      elevation: args.get<num>('elevation')?.toDouble(),
      titlePadding: args.getOr<EdgeInsetsGeometry>(
        'titlePadding',
        const EdgeInsets.fromLTRB(24, 24, 24, 0),
      ),
      contentPadding: args.getOr<EdgeInsetsGeometry>(
        'contentPadding',
        const EdgeInsets.fromLTRB(0, 12, 0, 16),
      ),
      insetPadding: args.get<EdgeInsets>('insetPadding'),
      children: children,
    );
  }
}

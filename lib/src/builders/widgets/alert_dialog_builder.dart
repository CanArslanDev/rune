import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds Material [AlertDialog] - a modal surface typically shown via
/// the imperative `showDialog(...)` bridge.
///
/// Supported named arguments:
/// - `title` ([Widget]?) - the dialog's title (typically a `Text`).
/// - `content` ([Widget]?) - the dialog's body content.
/// - `actions` (`List<Widget>?`) - action buttons such as `TextButton`.
///   Non-[Widget] entries are silently dropped, matching the
///   Column/Row children-filter convention.
/// - `backgroundColor` ([Color]?).
/// - `elevation` ([num]? coerced to double).
/// - `icon` ([Widget]?) - decorative leading icon.
/// - `iconColor` ([Color]?).
/// - `titleTextStyle` ([TextStyle]?).
/// - `contentTextStyle` ([TextStyle]?).
/// - `insetPadding` ([EdgeInsets]?). When omitted, [AlertDialog] falls
///   back to its theme default, matching Flutter's own behaviour.
///
/// Dialog `shape` is intentionally out of scope; consumers that need
/// custom shapes should wrap the dialog's `content` in their own widget.
final class AlertDialogBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const AlertDialogBuilder();

  @override
  String get typeName => 'AlertDialog';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final rawActions = args.get<List<Object?>>('actions');
    final actions = rawActions?.whereType<Widget>().toList(growable: false);
    return AlertDialog(
      title: args.get<Widget>('title'),
      content: args.get<Widget>('content'),
      actions: actions,
      backgroundColor: args.get<Color>('backgroundColor'),
      elevation: args.get<num>('elevation')?.toDouble(),
      icon: args.get<Widget>('icon'),
      iconColor: args.get<Color>('iconColor'),
      titleTextStyle: args.get<TextStyle>('titleTextStyle'),
      contentTextStyle: args.get<TextStyle>('contentTextStyle'),
      insetPadding: args.get<EdgeInsets>('insetPadding'),
    );
  }
}

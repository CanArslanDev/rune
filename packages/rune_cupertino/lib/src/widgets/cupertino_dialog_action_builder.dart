import 'package:flutter/cupertino.dart';
import 'package:rune/rune.dart';

/// Builds [CupertinoDialogAction], the button widget used inside a
/// [CupertinoAlertDialog]'s `actions` slot.
///
/// Supported named arguments:
/// - `child` ([Widget], required) - button label (typically a `Text`).
/// - `onPressed` (`String` or closure) - dispatched on tap. Missing or
///   null leaves the action disabled.
/// - `isDefaultAction` (`bool`) - defaults to `false`. Renders the label
///   in bold to indicate the preferred action.
/// - `isDestructiveAction` (`bool`) - defaults to `false`. Renders the
///   label in the iOS destructive-red style.
/// - `textStyle` ([TextStyle]?) - override the default label style.
final class CupertinoDialogActionBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const CupertinoDialogActionBuilder();

  @override
  String get typeName => 'CupertinoDialogAction';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return CupertinoDialogAction(
      onPressed: voidEventCallback(args.named['onPressed'], ctx.events),
      isDefaultAction: args.getOr<bool>('isDefaultAction', false),
      isDestructiveAction: args.getOr<bool>('isDestructiveAction', false),
      textStyle: args.get<TextStyle>('textStyle'),
      child: args.require<Widget>('child', source: 'CupertinoDialogAction'),
    );
  }
}

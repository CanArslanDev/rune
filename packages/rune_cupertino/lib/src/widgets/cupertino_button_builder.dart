import 'package:flutter/cupertino.dart';
import 'package:rune/rune.dart';

/// Builds [CupertinoButton]. `onPressed` in source is either a `String`
/// event name dispatched through `ctx.events`, or a closure. Missing or
/// null `onPressed` leaves the button disabled.
///
/// Supported named arguments:
/// - `child` ([Widget], required) - button label content.
/// - `onPressed` (`String` or closure) - tap handler.
/// - `color` ([Color]?) - background color.
/// - `disabledColor` ([Color]?) - background when `onPressed` is null.
/// - `padding` ([EdgeInsets]?) - inner padding override.
/// - `borderRadius` ([BorderRadius]?) - corner radius override.
/// - `pressedOpacity` (`num?`) - defaults to Flutter's own default.
final class CupertinoButtonBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const CupertinoButtonBuilder();

  @override
  String get typeName => 'CupertinoButton';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final pressedOpacity = args.get<num>('pressedOpacity')?.toDouble() ?? 0.4;
    return CupertinoButton(
      onPressed: voidEventCallback(args.named['onPressed'], ctx.events),
      color: args.get<Color>('color'),
      disabledColor: args.get<Color>('disabledColor') ??
          CupertinoColors.quaternarySystemFill,
      padding: args.get<EdgeInsets>('padding'),
      borderRadius: args.get<BorderRadius>('borderRadius'),
      pressedOpacity: pressedOpacity,
      child: args.require<Widget>('child', source: 'CupertinoButton'),
    );
  }
}

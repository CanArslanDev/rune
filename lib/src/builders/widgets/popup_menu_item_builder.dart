import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/event_callback.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds Material [PopupMenuItem] parametric on [Object?] so any
/// runtime value can serve as the item's identity.
///
/// Source arguments:
/// - `value` (any type, required - presence checked rather than
///   non-null because a legitimate null is allowed by
///   `PopupMenuItem<Object?>`). Raises [ArgumentException] when the
///   key is absent.
/// - `child` ([Widget], required).
/// - `enabled` ([bool]?). Defaults to `true`.
/// - `onTap` (`String` event name or `RuneClosure`). Fired when the
///   item is tapped in addition to the enclosing `PopupMenuButton`'s
///   `onSelected` callback.
/// - `padding` ([EdgeInsets]?).
/// - `height` ([num]? coerced to double). Minimum menu-item height.
final class PopupMenuItemBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const PopupMenuItemBuilder();

  @override
  String get typeName => 'PopupMenuItem';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    if (!args.named.containsKey('value')) {
      throw const ArgumentException(
        'PopupMenuItem',
        'Missing required argument "value"',
      );
    }
    final value = args.named['value'];
    final child = args.require<Widget>('child', source: 'PopupMenuItem');
    return PopupMenuItem<Object?>(
      value: value,
      enabled: args.getOr<bool>('enabled', true),
      onTap: voidEventCallback(args.named['onTap'], ctx.events),
      padding: args.get<EdgeInsets>('padding'),
      height: args.get<num>('height')?.toDouble() ?? kMinInteractiveDimension,
      child: child,
    );
  }
}

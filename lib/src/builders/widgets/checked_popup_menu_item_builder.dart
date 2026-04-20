import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/event_callback.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds Material [CheckedPopupMenuItem] parametric on [Object?] so any
/// runtime value can serve as the item's identity (v1.12.0).
///
/// Source arguments:
/// - `value` (any type, required - presence checked rather than
///   non-null because a legitimate null is allowed by
///   `CheckedPopupMenuItem<Object?>`). Raises [ArgumentException] when
///   the key is absent.
/// - `child` ([Widget], required).
/// - `checked` ([bool]?). Defaults to `false`. When `true`, a leading
///   check icon is drawn.
/// - `enabled` ([bool]?). Defaults to `true`.
/// - `onTap` (`String` event name or `RuneClosure`). Fired when the
///   item is tapped in addition to the enclosing `PopupMenuButton`'s
///   `onSelected` callback.
/// - `padding` ([EdgeInsets]?).
final class CheckedPopupMenuItemBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const CheckedPopupMenuItemBuilder();

  @override
  String get typeName => 'CheckedPopupMenuItem';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    if (!args.named.containsKey('value')) {
      throw const ArgumentException(
        'CheckedPopupMenuItem',
        'Missing required argument "value"',
      );
    }
    final value = args.named['value'];
    final child =
        args.require<Widget>('child', source: 'CheckedPopupMenuItem');
    return CheckedPopupMenuItem<Object?>(
      value: value,
      checked: args.getOr<bool>('checked', false),
      enabled: args.getOr<bool>('enabled', true),
      onTap: voidEventCallback(args.named['onTap'], ctx.events),
      padding: args.get<EdgeInsets>('padding'),
      child: child,
    );
  }
}

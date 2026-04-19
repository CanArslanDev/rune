import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds Material [DropdownMenuItem] parametric on [Object?] so any
/// runtime value (int, String, enum-ish key) can serve as the item's
/// identity.
///
/// Source arguments:
/// - `value` (any type) — required; this item's identity in the
///   enclosing [DropdownButton]. Unlike [ResolvedArguments.require],
///   an explicit `null` is legitimate for `DropdownMenuItem<Object?>`,
///   so this builder checks for *presence* of the key via
///   `args.named.containsKey('value')` and throws [ArgumentException]
///   only when the key is absent.
/// - `child` (`Widget`) — required; what the item renders (typically
///   a `Text`).
/// - `enabled` (`bool`) — optional; defaults to `true`. When `false`,
///   the item is rendered but not selectable.
final class DropdownMenuItemBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const DropdownMenuItemBuilder();

  @override
  String get typeName => 'DropdownMenuItem';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    if (!args.named.containsKey('value')) {
      throw const ArgumentException(
        'DropdownMenuItem',
        'Missing required argument "value"',
      );
    }
    // `value` may legitimately be null for DropdownMenuItem<Object?>, so
    // read it from the named map directly rather than through `require`.
    final value = args.named['value'];
    final child = args.require<Widget>('child', source: 'DropdownMenuItem');
    return DropdownMenuItem<Object?>(
      value: value,
      enabled: args.getOr<bool>('enabled', true),
      child: child,
    );
  }
}

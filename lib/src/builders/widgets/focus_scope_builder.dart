import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/event_callback.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds a [FocusScope] -- establishes a new focus scope that binds its
/// descendants into a shared traversal group.
///
/// Source arguments:
/// - `child` ([Widget], required) -- the wrapped subtree.
/// - `autofocus` (`bool`) -- defaults to `false`.
/// - `canRequestFocus` (`bool`) -- defaults to `true`.
/// - `onFocusChange` (`String` or closure `(bool) => ...`).
///
/// A [FocusScopeNode] slot is intentionally not exposed for v1.5.0;
/// FocusScope creates its own internal node, which covers the common
/// "declare a focus boundary around this form" case. Source-owned
/// FocusScopeNodes can be added in a later release if demand materializes.
final class FocusScopeBuilder implements RuneWidgetBuilder {
  /// Const constructor -- the builder is stateless.
  const FocusScopeBuilder();

  @override
  String get typeName => 'FocusScope';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return FocusScope(
      autofocus: args.getOr<bool>('autofocus', false),
      canRequestFocus: args.getOr<bool>('canRequestFocus', true),
      onFocusChange: valueEventCallback<bool>(
        args.named['onFocusChange'],
        ctx.events,
      ),
      child: args.require<Widget>('child', source: 'FocusScope'),
    );
  }
}

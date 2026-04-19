import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/event_callback.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds a [Focus] wrapper -- lets source opt a subtree into the
/// keyboard/focus traversal hierarchy with an optional host-supplied
/// [FocusNode].
///
/// Source arguments:
/// - `child` ([Widget], required) -- the wrapped subtree.
/// - `focusNode` ([FocusNode]) -- an externally-owned node, typically
///   constructed at source level via the `FocusNode()` value builder
///   inside a `StatefulBuilder(initial: {...}, dispose: ...)`.
///   Absence leaves Flutter's default behavior (Focus creates its own
///   internal node).
/// - `autofocus` (`bool`) -- defaults to `false`. When `true`, the
///   enclosing `FocusScope` requests focus for this node on first
///   mount.
/// - `canRequestFocus` (`bool`) -- defaults to `true`.
/// - `onFocusChange` (`String` or closure `(bool) => ...`) -- fires when
///   the child gains or loses focus.
///
/// The `onKey` / `onKeyEvent` slots are intentionally omitted;
/// closure-shaped keyboard handlers are deferred to a later release.
final class FocusBuilder implements RuneWidgetBuilder {
  /// Const constructor -- the builder is stateless.
  const FocusBuilder();

  @override
  String get typeName => 'Focus';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return Focus(
      focusNode: args.get<FocusNode>('focusNode'),
      autofocus: args.getOr<bool>('autofocus', false),
      canRequestFocus: args.getOr<bool>('canRequestFocus', true),
      onFocusChange: valueEventCallback<bool>(
        args.named['onFocusChange'],
        ctx.events,
      ),
      child: args.require<Widget>('child', source: 'Focus'),
    );
  }
}

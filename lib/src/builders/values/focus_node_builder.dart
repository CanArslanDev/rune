import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds a [FocusNode] from Dart's default constructor.
///
/// Source arguments (all optional):
/// - `debugLabel` (`String`): diagnostic label for inspector traces.
/// - `skipTraversal` (`bool`): whether the node is skipped during focus
///   traversal. Defaults to `false`.
/// - `canRequestFocus` (`bool`): whether the node can accept focus.
///   Defaults to `true`.
/// - `descendantsAreFocusable` (`bool`): whether descendants can be
///   focused. Defaults to `true`.
/// - `descendantsAreTraversable` (`bool`): whether descendants are
///   included in focus traversal. Defaults to `true`.
///
/// Key-event callbacks (`onKey`, `onKeyEvent`) are intentionally omitted;
/// closure-shaped keyboard handlers are deferred to a later release.
///
/// ```
/// StatefulBuilder(
///   initial: {'focus': FocusNode()},
///   dispose: (state) => state.focus.dispose(),
///   builder: (state) => TextField(focusNode: state.focus),
/// )
/// ```
final class FocusNodeBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const FocusNodeBuilder();

  @override
  String get typeName => 'FocusNode';

  @override
  String? get constructorName => null;

  @override
  FocusNode build(ResolvedArguments args, RuneContext ctx) {
    return FocusNode(
      debugLabel: args.get<String>('debugLabel'),
      skipTraversal: args.getOr<bool>('skipTraversal', false),
      canRequestFocus: args.getOr<bool>('canRequestFocus', true),
      descendantsAreFocusable: args.getOr<bool>(
        'descendantsAreFocusable',
        true,
      ),
      descendantsAreTraversable: args.getOr<bool>(
        'descendantsAreTraversable',
        true,
      ),
    );
  }
}

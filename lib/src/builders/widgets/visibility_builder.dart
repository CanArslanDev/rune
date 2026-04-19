import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [Visibility] — conditionally renders its required `child`
/// according to `visible` (defaults to `true`). When `visible` is
/// `false`, `replacement` (defaulting to `SizedBox.shrink()`) is
/// rendered in its place.
///
/// The `maintainState`, `maintainAnimation`, and `maintainSize` flags
/// all default to `false`, matching Flutter's own defaults.
final class VisibilityBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const VisibilityBuilder();

  @override
  String get typeName => 'Visibility';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return Visibility(
      visible: args.getOr<bool>('visible', true),
      replacement: args.getOr<Widget>(
        'replacement',
        const SizedBox.shrink(),
      ),
      maintainState: args.getOr<bool>('maintainState', false),
      maintainAnimation: args.getOr<bool>('maintainAnimation', false),
      maintainSize: args.getOr<bool>('maintainSize', false),
      child: args.require<Widget>('child', source: 'Visibility'),
    );
  }
}

import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [FadeTransition]. Drives child opacity from an
/// [Animation] of `double`.
///
/// Source arguments:
/// - `opacity` (required, `Animation<double>`): typically an
///   `AnimationController` or `CurvedAnimation` declared via a
///   `StatefulBuilder.initial` map.
/// - `child` (optional, [Widget]).
/// - `alwaysIncludeSemantics` (optional, `bool`): defaults to `false`.
final class FadeTransitionBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const FadeTransitionBuilder();

  @override
  String get typeName => 'FadeTransition';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return FadeTransition(
      opacity: args.require<Animation<double>>(
        'opacity',
        source: 'FadeTransition',
      ),
      alwaysIncludeSemantics:
          args.getOr<bool>('alwaysIncludeSemantics', false),
      child: args.get<Widget>('child'),
    );
  }
}

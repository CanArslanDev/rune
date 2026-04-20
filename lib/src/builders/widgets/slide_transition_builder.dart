import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [SlideTransition]. Drives child translation from an
/// [Animation] of [Offset].
///
/// Source arguments:
/// - `position` (required, `Animation<Offset>`): typically a
///   `Tween<Offset>.animate(controller)` in Dart, or a pre-built
///   `Animation<Offset>` supplied via host `data`.
/// - `child` (optional, [Widget]).
/// - `transformHitTests` (optional, `bool`): defaults to `true`.
/// - `textDirection` (optional, [TextDirection]).
final class SlideTransitionBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const SlideTransitionBuilder();

  @override
  String get typeName => 'SlideTransition';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return SlideTransition(
      position: args.require<Animation<Offset>>(
        'position',
        source: 'SlideTransition',
      ),
      transformHitTests: args.getOr<bool>('transformHitTests', true),
      textDirection: args.get<TextDirection>('textDirection'),
      child: args.get<Widget>('child'),
    );
  }
}

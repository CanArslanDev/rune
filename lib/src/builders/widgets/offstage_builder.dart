import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [Offstage] — when `offstage` is `true` (the default), the
/// `child` is laid out with zero size but keeps its State mounted so
/// animations, controllers, and subscriptions keep running. When
/// `false`, the child is rendered normally.
final class OffstageBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const OffstageBuilder();

  @override
  String get typeName => 'Offstage';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return Offstage(
      offstage: args.getOr<bool>('offstage', true),
      child: args.get<Widget>('child'),
    );
  }
}

import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [Opacity] — the static (non-animated) complement to
/// `AnimatedOpacity`. Required `opacity` accepts any [num] and is
/// coerced to `double` (`0.0` = fully transparent, `1.0` = fully
/// opaque). Optional `alwaysIncludeSemantics` defaults to `false`.
final class OpacityBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const OpacityBuilder();

  @override
  String get typeName => 'Opacity';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return Opacity(
      opacity: args.require<num>('opacity', source: 'Opacity').toDouble(),
      alwaysIncludeSemantics: args.getOr<bool>(
        'alwaysIncludeSemantics',
        false,
      ),
      child: args.get<Widget>('child'),
    );
  }
}

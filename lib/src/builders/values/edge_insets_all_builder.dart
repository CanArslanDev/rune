import 'package:flutter/painting.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds `EdgeInsets.all(num)` from a single positional numeric argument.
final class EdgeInsetsAllBuilder implements RuneValueBuilder {
  /// Const constructor — the builder is stateless.
  const EdgeInsetsAllBuilder();

  @override
  String get typeName => 'EdgeInsets';

  @override
  String? get constructorName => 'all';

  /// Builds an [EdgeInsets.all] from the first positional argument, which
  /// must be a [num] (int or double). The value is converted to [double].
  @override
  EdgeInsets build(ResolvedArguments args, RuneContext ctx) {
    final value = args.requirePositional<num>(0, source: 'EdgeInsets.all');
    return EdgeInsets.all(value.toDouble());
  }
}

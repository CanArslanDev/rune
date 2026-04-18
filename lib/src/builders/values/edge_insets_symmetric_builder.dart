import 'package:flutter/painting.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds `EdgeInsets.symmetric(horizontal:, vertical:)` from optional
/// numeric named arguments. Missing axes default to `0` — matching
/// Flutter's own defaults.
final class EdgeInsetsSymmetricBuilder implements RuneValueBuilder {
  /// Const constructor — the builder is stateless.
  const EdgeInsetsSymmetricBuilder();

  @override
  String get typeName => 'EdgeInsets';

  @override
  String? get constructorName => 'symmetric';

  /// Builds an [EdgeInsets.symmetric] from optional `horizontal` and
  /// `vertical` named arguments. Both default to `0.0` when absent.
  @override
  EdgeInsets build(ResolvedArguments args, RuneContext ctx) {
    return EdgeInsets.symmetric(
      horizontal: args.get<num>('horizontal')?.toDouble() ?? 0.0,
      vertical: args.get<num>('vertical')?.toDouble() ?? 0.0,
    );
  }
}

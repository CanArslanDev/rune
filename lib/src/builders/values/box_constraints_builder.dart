import 'package:flutter/rendering.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds `BoxConstraints(minWidth, maxWidth, minHeight, maxHeight)`.
///
/// All four named arguments are optional nums (coerced to double).
/// Missing edges fall back to Flutter's own defaults: `0.0` for the
/// minimums and `double.infinity` for the maximums.
///
/// Registered as a [RuneValueBuilder] under the default constructor
/// (`constructorName == null`), so source like
/// `BoxConstraints(minWidth: 100, maxWidth: 200)` resolves directly
/// to a Dart [BoxConstraints] value. Named ctors
/// (`BoxConstraints.tight`, `.loose`, `.expand`, `.tightFor`) are
/// deferred to separate builders.
final class BoxConstraintsBuilder implements RuneValueBuilder {
  /// Const constructor — the builder is stateless.
  const BoxConstraintsBuilder();

  @override
  String get typeName => 'BoxConstraints';

  @override
  String? get constructorName => null;

  @override
  BoxConstraints build(ResolvedArguments args, RuneContext ctx) {
    return BoxConstraints(
      minWidth: args.get<num>('minWidth')?.toDouble() ?? 0.0,
      maxWidth: args.get<num>('maxWidth')?.toDouble() ?? double.infinity,
      minHeight: args.get<num>('minHeight')?.toDouble() ?? 0.0,
      maxHeight: args.get<num>('maxHeight')?.toDouble() ?? double.infinity,
    );
  }
}

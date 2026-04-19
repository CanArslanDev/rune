import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds `Offset(dx, dy)`. Both arguments are required positional nums
/// (coerced to double). Used alongside `Transform.translate` and anywhere
/// else in the Flutter API that takes an [Offset].
///
/// Registered as a [RuneValueBuilder] under the default constructor
/// (`constructorName == null`), so source like `Offset(10, 20)` resolves
/// directly to a Dart [Offset] value.
final class OffsetBuilder implements RuneValueBuilder {
  /// Const constructor — the builder is stateless.
  const OffsetBuilder();

  @override
  String get typeName => 'Offset';

  @override
  String? get constructorName => null;

  @override
  Offset build(ResolvedArguments args, RuneContext ctx) {
    final dx = args.requirePositional<num>(0, source: 'Offset').toDouble();
    final dy = args.requirePositional<num>(1, source: 'Offset').toDouble();
    return Offset(dx, dy);
  }
}

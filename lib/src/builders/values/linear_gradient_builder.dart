import 'package:flutter/painting.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/exceptions.dart' show ArgumentException;
import 'package:rune/src/core/rune_context.dart';

/// Builds `LinearGradient(colors, begin?, end?, stops?, tileMode?)`.
/// `colors` is required. `begin` / `end` accept any [AlignmentGeometry];
/// default `Alignment.centerLeft` → `Alignment.centerRight`. `stops` is
/// an optional `List<num>` coerced to `List<double>`.
final class LinearGradientBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const LinearGradientBuilder();

  @override
  String get typeName => 'LinearGradient';

  @override
  String? get constructorName => null;

  @override
  LinearGradient build(ResolvedArguments args, RuneContext ctx) {
    final colors = args.require<List<Object?>>(
      'colors',
      source: 'LinearGradient',
    );
    return LinearGradient(
      begin: args.get<AlignmentGeometry>('begin') ?? Alignment.centerLeft,
      end: args.get<AlignmentGeometry>('end') ?? Alignment.centerRight,
      colors: colors.cast<Color>(),
      stops: _stops(args.get<List<Object?>>('stops')),
      tileMode: args.get<TileMode>('tileMode') ?? TileMode.clamp,
    );
  }
}

List<double>? _stops(List<Object?>? raw) {
  if (raw == null) return null;
  return <double>[
    for (final entry in raw)
      if (entry is num)
        entry.toDouble()
      else
        throw ArgumentException(
          'LinearGradient',
          'stops entries must be num, got ${entry.runtimeType}',
        ),
  ];
}

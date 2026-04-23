import 'package:flutter/painting.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/exceptions.dart' show ArgumentException;
import 'package:rune/src/core/rune_context.dart';

/// Builds `RadialGradient(colors, center?, radius?, stops?, tileMode?)`.
/// `colors` is required. `center` defaults to `Alignment.center`; `radius`
/// defaults to `0.5`. `stops` is an optional `List<num>` coerced to
/// `List<double>`.
final class RadialGradientBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const RadialGradientBuilder();

  @override
  String get typeName => 'RadialGradient';

  @override
  String? get constructorName => null;

  @override
  RadialGradient build(ResolvedArguments args, RuneContext ctx) {
    final colors = args.require<List<Object?>>(
      'colors',
      source: 'RadialGradient',
    );
    return RadialGradient(
      center: args.get<AlignmentGeometry>('center') ?? Alignment.center,
      radius: args.get<num>('radius')?.toDouble() ?? 0.5,
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
          'RadialGradient',
          'stops entries must be num, got ${entry.runtimeType}',
        ),
  ];
}

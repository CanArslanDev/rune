import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/exceptions.dart' show ArgumentException;
import 'package:rune/src/core/rune_context.dart';

/// Builds
/// `SweepGradient(colors, center?, startAngle?, endAngle?, stops?,
/// tileMode?)`. `colors` is required. `center` defaults to
/// `Alignment.center`; `startAngle` / `endAngle` default to `0.0` and
/// `2 * pi` so the sweep covers a full circle.
final class SweepGradientBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const SweepGradientBuilder();

  @override
  String get typeName => 'SweepGradient';

  @override
  String? get constructorName => null;

  @override
  SweepGradient build(ResolvedArguments args, RuneContext ctx) {
    final colors = args.require<List<Object?>>(
      'colors',
      source: 'SweepGradient',
    );
    return SweepGradient(
      center: args.get<AlignmentGeometry>('center') ?? Alignment.center,
      startAngle: args.get<num>('startAngle')?.toDouble() ?? 0.0,
      endAngle: args.get<num>('endAngle')?.toDouble() ?? math.pi * 2,
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
          'SweepGradient',
          'stops entries must be num, got ${entry.runtimeType}',
        ),
  ];
}

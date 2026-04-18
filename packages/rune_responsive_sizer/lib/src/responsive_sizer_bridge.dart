import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:rune/rune.dart';

/// A [RuneBridge] that registers percent-of-screen and text-scale
/// property extensions on a [RuneConfig]'s extensions registry.
///
/// Supported properties (each expects a numeric target):
///
/// | Property | Meaning                                    | Example         |
/// | -------- | ------------------------------------------ | --------------- |
/// | `.w`     | Percentage of screen width                 | `50.w` = half W |
/// | `.h`     | Percentage of screen height                | `50.h` = half H |
/// | `.sp`    | Text-scaled pixels (via textScaler)        | `16.sp`         |
/// | `.dm`    | Percentage of min(width, height)           | `10.dm`         |
///
/// All four handlers require a live `ctx.flutterContext` (i.e. the
/// source must render through `RuneView`, which threads the enclosing
/// [BuildContext]). Invoking any property without a flutter context
/// throws a [StateError]. Non-numeric targets throw [ArgumentError].
final class ResponsiveSizerBridge implements RuneBridge {
  /// Const constructor — the bridge is stateless.
  const ResponsiveSizerBridge();

  @override
  void registerInto(RuneConfig config) {
    config.extensions
      ..register('w', _widthPercent)
      ..register('h', _heightPercent)
      ..register('sp', _scaledPixels)
      ..register('dm', _diagonalMinPercent);
  }

  static double _widthPercent(Object? target, RuneContext ctx) {
    final value = _asNum(target, '.w');
    final ctx2 = _requireFlutterContext(ctx, '.w');
    return MediaQuery.sizeOf(ctx2).width * value / 100.0;
  }

  static double _heightPercent(Object? target, RuneContext ctx) {
    final value = _asNum(target, '.h');
    final ctx2 = _requireFlutterContext(ctx, '.h');
    return MediaQuery.sizeOf(ctx2).height * value / 100.0;
  }

  static double _scaledPixels(Object? target, RuneContext ctx) {
    final value = _asNum(target, '.sp');
    final ctx2 = _requireFlutterContext(ctx, '.sp');
    final scaler = MediaQuery.textScalerOf(ctx2);
    return scaler.scale(value.toDouble());
  }

  static double _diagonalMinPercent(Object? target, RuneContext ctx) {
    final value = _asNum(target, '.dm');
    final ctx2 = _requireFlutterContext(ctx, '.dm');
    final size = MediaQuery.sizeOf(ctx2);
    final smaller = math.min(size.width, size.height);
    return smaller * value / 100.0;
  }

  static num _asNum(Object? target, String property) {
    if (target is num) return target;
    throw ArgumentError(
      '$property expects a num target, got ${target.runtimeType}',
    );
  }

  static BuildContext _requireFlutterContext(
    RuneContext ctx,
    String property,
  ) {
    final flutterCtx = ctx.flutterContext;
    if (flutterCtx == null) {
      throw StateError(
        '$property requires a live BuildContext (reached only through a '
        'RuneView render); ctx.flutterContext was null.',
      );
    }
    return flutterCtx;
  }
}

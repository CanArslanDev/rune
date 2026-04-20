import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

/// A declarative description of a Flutter [AnimationController].
///
/// Rune source cannot construct a real [AnimationController] during value
/// resolution because the controller requires a `vsync` [TickerProvider]
/// that only the enclosing `StatefulBuilder` widget state can supply.
/// The `AnimationController(...)` value builder therefore returns this
/// pure-data spec. When the hosting `_StatefulHost` state materializes
/// its `initial` bag, it walks each entry and replaces every
/// [AnimationControllerSpec] with a freshly-constructed
/// [AnimationController] bound to its own [TickerProvider]. The spec
/// pattern keeps value resolution free of widget-tree dependencies and
/// defers construction to the point where a vsync is available.
@immutable
final class AnimationControllerSpec {
  /// Constructs a new spec capturing every parameter the value builder
  /// accepts. Materialization turns this into a real
  /// [AnimationController] with the same arguments plus `vsync: state`.
  const AnimationControllerSpec({
    required this.duration,
    this.reverseDuration,
    this.lowerBound = 0.0,
    this.upperBound = 1.0,
    this.animationBehavior = AnimationBehavior.normal,
    this.initialValue,
    this.debugLabel,
  });

  /// Forward-direction duration. Required; mirrors Flutter's
  /// [AnimationController.duration].
  final Duration duration;

  /// Reverse-direction duration, or `null` to fall back to [duration].
  final Duration? reverseDuration;

  /// Lower bound of the animation value. Defaults to `0.0`.
  final double lowerBound;

  /// Upper bound of the animation value. Defaults to `1.0`.
  final double upperBound;

  /// Tick cadence policy; defaults to [AnimationBehavior.normal].
  final AnimationBehavior animationBehavior;

  /// Initial value at construction time, or `null` to default to
  /// [lowerBound].
  final double? initialValue;

  /// Optional debug label plumbed through to the materialized
  /// [AnimationController] for diagnostics.
  final String? debugLabel;
}

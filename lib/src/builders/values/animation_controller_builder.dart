import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/animation_controller_spec.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds an [AnimationControllerSpec] from Rune source.
///
/// Unlike most value builders which return a ready-to-use Flutter value,
/// this builder returns a pure-data spec. Constructing a real
/// `AnimationController` requires a `vsync` `TickerProvider`, and no
/// such provider exists during value resolution. Instead, the spec is
/// stored in the `initial:` map of a `StatefulBuilder`; the private
/// `_StatefulHost` state walks that map during `initState` and replaces
/// every spec with an actual controller bound to its own
/// `TickerProvider`, disposing them on unmount.
///
/// Source arguments (all optional):
/// - `duration` ([Duration]): forward-direction duration. Required for
///   controllers that `forward` or `repeat`; the builder currently
///   requires it.
/// - `reverseDuration` ([Duration]): reverse-direction duration.
/// - `lowerBound` (`num`): lower bound of `.value`. Defaults to `0.0`.
/// - `upperBound` (`num`): upper bound of `.value`. Defaults to `1.0`.
/// - `value` (`num`): initial value.
/// - `debugLabel` (`String`): diagnostics label.
///
/// ```
/// StatefulBuilder(
///   initial: {
///     'ctrl': AnimationController(duration: Duration(seconds: 2)),
///   },
///   initState: (state) => state.ctrl.repeat(),
///   builder: (state) => RotationTransition(
///     turns: state.ctrl,
///     child: Icon(Icons.refresh),
///   ),
/// )
/// ```
final class AnimationControllerBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const AnimationControllerBuilder();

  @override
  String get typeName => 'AnimationController';

  @override
  String? get constructorName => null;

  @override
  AnimationControllerSpec build(ResolvedArguments args, RuneContext ctx) {
    return AnimationControllerSpec(
      duration: args.require<Duration>(
        'duration',
        source: 'AnimationController',
      ),
      reverseDuration: args.get<Duration>('reverseDuration'),
      lowerBound: args.get<num>('lowerBound')?.toDouble() ?? 0.0,
      upperBound: args.get<num>('upperBound')?.toDouble() ?? 1.0,
      initialValue: args.get<num>('value')?.toDouble(),
      debugLabel: args.get<String>('debugLabel'),
    );
  }
}

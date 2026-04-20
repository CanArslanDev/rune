import 'package:flutter/cupertino.dart';
import 'package:rune/rune.dart';

/// Builds [CupertinoSlider] with value-change dispatch.
///
/// Source arguments:
/// - `value` (`num`) - required; coerced to `double`. Current position.
/// - `min` (`num`) - optional, defaults to `0.0`. Coerced to `double`.
/// - `max` (`num`) - optional, defaults to `1.0`. Coerced to `double`.
/// - `divisions` (`int?`) - optional; enables snap-to-ticks.
/// - `onChanged` (`String?` or closure) - receives the new `double` on
///   drag. Missing `onChanged` disables the slider.
/// - `activeColor` ([Color]?) - filled portion color.
/// - `thumbColor` ([Color]?) - thumb color; defaults to white.
final class CupertinoSliderBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const CupertinoSliderBuilder();

  @override
  String get typeName => 'CupertinoSlider';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return CupertinoSlider(
      value: args.require<num>('value', source: 'CupertinoSlider').toDouble(),
      min: args.get<num>('min')?.toDouble() ?? 0.0,
      max: args.get<num>('max')?.toDouble() ?? 1.0,
      divisions: args.get<int>('divisions'),
      activeColor: args.get<Color>('activeColor'),
      thumbColor: args.get<Color>('thumbColor') ?? CupertinoColors.white,
      onChanged: valueEventCallback<double>(
        args.named['onChanged'],
        ctx.events,
      ),
    );
  }
}

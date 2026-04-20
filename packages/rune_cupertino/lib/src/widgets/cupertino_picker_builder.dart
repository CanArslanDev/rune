import 'package:flutter/cupertino.dart';
import 'package:rune/rune.dart';

/// Builds [CupertinoPicker] from the concrete-children constructor.
///
/// Supported named arguments:
/// - `itemExtent` (`num`, required) - per-item height; coerced to
///   `double`. Must be greater than zero (Flutter asserts).
/// - `children` (`List<Widget>`) - the picker rows. Non-[Widget]
///   entries are silently dropped, matching the Column/Row
///   children-filter convention.
/// - `onSelectedItemChanged` (`String?` or closure) - fires with the
///   newly-selected index on scroll-stopped. Missing binding leaves
///   the picker non-reporting (the Flutter API still requires a
///   non-null callback, so we pass a no-op in that case).
/// - `scrollController` ([FixedExtentScrollController]?) - optional
///   controller for programmatic access.
/// - `backgroundColor` ([Color]?) - translucent backdrop behind the
///   wheel. When omitted, background painting is disabled entirely
///   (matching the native iOS picker look).
/// - `magnification` (`num`) - scale factor applied to the selected
///   row. Defaults to Flutter's own default (1.0).
/// - `squeeze` (`num`) - horizontal compression factor. Defaults to
///   Flutter's own default (1.45).
/// - `useMagnifier` (`bool`) - whether to render the selection-ring
///   magnifier. Defaults to `false`.
final class CupertinoPickerBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const CupertinoPickerBuilder();

  @override
  String get typeName => 'CupertinoPicker';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final itemExtent = args
        .require<num>('itemExtent', source: 'CupertinoPicker')
        .toDouble();
    final rawChildren = args.get<List<Object?>>('children');
    final children =
        rawChildren?.whereType<Widget>().toList(growable: false) ??
            const <Widget>[];
    final onChanged = valueEventCallback<int>(
      args.named['onSelectedItemChanged'],
      ctx.events,
    );
    return CupertinoPicker(
      itemExtent: itemExtent,
      onSelectedItemChanged: onChanged ?? (_) {},
      scrollController:
          args.get<FixedExtentScrollController>('scrollController'),
      backgroundColor: args.get<Color>('backgroundColor'),
      magnification: args.get<num>('magnification')?.toDouble() ?? 1.0,
      squeeze: args.get<num>('squeeze')?.toDouble() ?? 1.45,
      useMagnifier: args.getOr<bool>('useMagnifier', false),
      children: children,
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:rune/rune.dart';

/// Builds [CupertinoSegmentedControl] with a type argument of `Object`
/// so source-level maps can carry any non-null key type.
///
/// Supported named arguments:
/// - `children` (`Map<Object?, Widget>`, required) - ordered map of
///   segment keys to label widgets. The resolver delivers a plain
///   `Map<Object?, Object?>` from a source-level `{'a': Text('A'), ...}`
///   literal; this builder drops entries whose value is not a [Widget]
///   (matching the Column/Row children-filter convention). A `null`
///   key raises [ArgumentException] because Flutter's `T extends Object`
///   forbids null keys outright.
/// - `onValueChanged` (`String?` or closure) - dispatched with the
///   newly-selected key on tap. When omitted a no-op is passed
///   through, because Flutter's `onValueChanged` is non-nullable.
/// - `groupValue` (`Object?`) - currently-selected key. When omitted,
///   no segment appears selected.
/// - `borderColor`, `selectedColor`, `unselectedColor`, `pressedColor`
///   ([Color]?) - optional palette overrides.
final class CupertinoSegmentedControlBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const CupertinoSegmentedControlBuilder();

  @override
  String get typeName => 'CupertinoSegmentedControl';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final rawChildren = args.require<Map<Object?, Object?>>(
      'children',
      source: 'CupertinoSegmentedControl',
    );
    final children = <Object, Widget>{};
    for (final entry in rawChildren.entries) {
      final key = entry.key;
      final value = entry.value;
      if (key == null) {
        throw const ArgumentException(
          'CupertinoSegmentedControl',
          'children map keys must be non-null (got a null key)',
        );
      }
      if (value is Widget) {
        children[key] = value;
      }
    }
    final onChanged = valueEventCallback<Object>(
      args.named['onValueChanged'],
      ctx.events,
    );
    return CupertinoSegmentedControl<Object>(
      children: children,
      onValueChanged: onChanged ?? (_) {},
      groupValue: args.get<Object>('groupValue'),
      borderColor: args.get<Color>('borderColor'),
      selectedColor: args.get<Color>('selectedColor'),
      unselectedColor: args.get<Color>('unselectedColor'),
      pressedColor: args.get<Color>('pressedColor'),
    );
  }
}

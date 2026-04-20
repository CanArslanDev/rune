import 'package:flutter/cupertino.dart';
import 'package:rune/rune.dart';

/// Builds [CupertinoActionSheetAction], the button widget used inside a
/// [CupertinoActionSheet]'s `actions` slot.
///
/// `CupertinoActionSheetAction` is a [Widget] subclass in Flutter; Rune
/// registers it as a value builder so it composes naturally into the
/// sheet's typed `actions: List<CupertinoActionSheetAction>` slot. It
/// can also be used anywhere a [Widget] is expected because it is still
/// a widget at runtime.
///
/// Supported named arguments:
/// - `child` ([Widget], required) - the action's label widget
///   (typically a [Text]).
/// - `onPressed` (`String` or closure, required) - dispatched on tap.
///   Flutter's [CupertinoActionSheetAction.onPressed] is non-nullable,
///   so unlike dialog actions the callback must always be supplied.
/// - `isDefaultAction` (`bool`) - defaults to `false`. Renders the
///   label bold.
/// - `isDestructiveAction` (`bool`) - defaults to `false`. Renders the
///   label in the iOS destructive-red style.
final class CupertinoActionSheetActionBuilder
    implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const CupertinoActionSheetActionBuilder();

  @override
  String get typeName => 'CupertinoActionSheetAction';

  @override
  String? get constructorName => null;

  @override
  CupertinoActionSheetAction build(ResolvedArguments args, RuneContext ctx) {
    final child = args.require<Widget>(
      'child',
      source: 'CupertinoActionSheetAction',
    );
    final callback = voidEventCallback(args.named['onPressed'], ctx.events);
    if (callback == null) {
      throw const ArgumentException(
        'CupertinoActionSheetAction',
        'Missing required argument "onPressed"',
      );
    }
    return CupertinoActionSheetAction(
      onPressed: callback,
      isDefaultAction: args.getOr<bool>('isDefaultAction', false),
      isDestructiveAction: args.getOr<bool>('isDestructiveAction', false),
      child: child,
    );
  }
}

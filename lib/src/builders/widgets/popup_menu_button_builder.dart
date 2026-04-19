import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/closure_builder_helpers.dart';
import 'package:rune/src/builders/event_callback.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds Material [PopupMenuButton] parametric on [Object?].
///
/// Source arguments:
/// - `itemBuilder` (`RuneClosure (BuildContext) -> List<PopupMenuEntry>`)
///   required. Must be a single-parameter closure returning a list of
///   [PopupMenuEntry] values such as [PopupMenuItem] or
///   [PopupMenuDivider]. Non-entry returns are filtered out.
/// - `onSelected` (`String` event name or `RuneClosure`) optional.
///   Receives the selected item's `value`.
/// - `icon` ([Widget]?) optional leading icon. Mutually exclusive with
///   `child`.
/// - `child` ([Widget]?) optional alternative to `icon`.
/// - `tooltip` ([String]?) optional accessibility text.
/// - `elevation` ([num]? coerced to double).
/// - `padding` ([EdgeInsetsGeometry]?). Defaults to
///   `EdgeInsets.all(8.0)`.
/// - `enabled` ([bool]?). Defaults to `true`.
final class PopupMenuButtonBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const PopupMenuButtonBuilder();

  @override
  String get typeName => 'PopupMenuButton';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final itemBuilder = toPopupMenuItemBuilder(
      args.named['itemBuilder'],
      'PopupMenuButton',
    );
    return PopupMenuButton<Object?>(
      itemBuilder: itemBuilder,
      onSelected: valueEventCallback<Object?>(
        args.named['onSelected'],
        ctx.events,
      ),
      icon: args.get<Widget>('icon'),
      tooltip: args.get<String>('tooltip'),
      elevation: args.get<num>('elevation')?.toDouble(),
      padding: args.getOr<EdgeInsetsGeometry>(
        'padding',
        const EdgeInsets.all(8),
      ),
      enabled: args.getOr<bool>('enabled', true),
      initialValue: args.named['initialValue'],
      child: args.get<Widget>('child'),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds Material [Tab] — one labelled entry in a [TabBar.tabs] list.
///
/// Source arguments (all optional, but at least one of `text`/`icon`
/// must be supplied — Flutter's [Tab] asserts at construction time):
/// - `text` (`String?`) — tab label.
/// - `icon` (`Widget?`) — tab icon (typically `Icon(Icons.*)`).
/// - `iconMargin` (`EdgeInsetsGeometry?`) — spacing between icon and
///   text when both are present. Defaults to Flutter's
///   `EdgeInsets.only(bottom: 10.0)`.
///
/// Typically used inside a `TabBar` wrapped in a `DefaultTabController`
/// ancestor provided by the host app — Rune source is not expected to
/// construct the controller itself.
final class TabBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const TabBuilder();

  @override
  String get typeName => 'Tab';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return Tab(
      text: args.get<String>('text'),
      icon: args.get<Widget>('icon'),
      iconMargin: args.getOr<EdgeInsetsGeometry>(
        'iconMargin',
        const EdgeInsets.only(bottom: 10),
      ),
    );
  }
}

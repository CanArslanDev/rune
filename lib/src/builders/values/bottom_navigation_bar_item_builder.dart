import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [BottomNavigationBarItem] — a data class describing one tab
/// in a [BottomNavigationBar]. Required `icon` (Widget) and `label`
/// (String); optional `activeIcon`, `backgroundColor`, `tooltip`.
///
/// `backgroundColor` is only honoured by Flutter when the enclosing
/// [BottomNavigationBar] uses `type: BottomNavigationBarType.shifting`.
final class BottomNavigationBarItemBuilder implements RuneValueBuilder {
  /// Const constructor — the builder is stateless.
  const BottomNavigationBarItemBuilder();

  @override
  String get typeName => 'BottomNavigationBarItem';

  @override
  String? get constructorName => null;

  @override
  BottomNavigationBarItem build(ResolvedArguments args, RuneContext ctx) {
    return BottomNavigationBarItem(
      icon: args.require<Widget>('icon', source: 'BottomNavigationBarItem'),
      label: args.require<String>('label', source: 'BottomNavigationBarItem'),
      activeIcon: args.get<Widget>('activeIcon'),
      backgroundColor: args.get<Color>('backgroundColor'),
      tooltip: args.get<String>('tooltip'),
    );
  }
}

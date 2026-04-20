import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rune/rune.dart';

/// Builds a `MaterialApp.router(routerConfig: router)` widget that
/// installs a supplied [GoRouter] at the root of the tree.
///
/// Supported named arguments:
/// - `router` ([GoRouter], required) - the router to install.
/// - `title` ([String]?) - app title; forwarded to `MaterialApp`.
/// - `debugShowCheckedModeBanner` ([bool]?) - suppress the
///   debug-build banner.
/// - `theme` ([ThemeData]?) - ordinary `MaterialApp.theme` slot.
///
/// Use this widget as the root of a `RuneView`'s output when the
/// source declares the whole app's routing structure inline.
final class GoRouterAppBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const GoRouterAppBuilder();

  @override
  String get typeName => 'GoRouterApp';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final router = args.require<GoRouter>('router', source: 'GoRouterApp');
    return MaterialApp.router(
      routerConfig: router,
      title: args.get<String>('title') ?? '',
      theme: args.get<ThemeData>('theme'),
      debugShowCheckedModeBanner:
          args.get<bool>('debugShowCheckedModeBanner') ?? true,
    );
  }
}

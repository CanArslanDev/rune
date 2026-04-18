import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [Scaffold] from optional `appBar` ([PreferredSizeWidget]; a
/// plain `Widget` resolved to something that isn't a [PreferredSizeWidget]
/// is silently dropped), `body`, `floatingActionButton`, `drawer`, and
/// `backgroundColor`.
final class ScaffoldBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const ScaffoldBuilder();

  @override
  String get typeName => 'Scaffold';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final rawAppBar = args.get<Widget>('appBar');
    return Scaffold(
      appBar: rawAppBar is PreferredSizeWidget ? rawAppBar : null,
      body: args.get<Widget>('body'),
      floatingActionButton: args.get<Widget>('floatingActionButton'),
      drawer: args.get<Widget>('drawer'),
      backgroundColor: args.get<Color>('backgroundColor'),
    );
  }
}

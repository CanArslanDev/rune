import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [AppBar] from optional `title`, `leading`, `actions` list,
/// `backgroundColor`, `elevation`, and `centerTitle`.
final class AppBarBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const AppBarBuilder();

  @override
  String get typeName => 'AppBar';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final actions = (args.get<List<Object?>>('actions') ??
            const <Object?>[])
        .whereType<Widget>()
        .toList(growable: false);
    return AppBar(
      title: args.get<Widget>('title'),
      leading: args.get<Widget>('leading'),
      actions: actions.isEmpty ? null : actions,
      backgroundColor: args.get<Color>('backgroundColor'),
      elevation: args.get<num>('elevation')?.toDouble(),
      centerTitle: args.get<bool>('centerTitle'),
    );
  }
}

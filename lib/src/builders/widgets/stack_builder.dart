import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [Stack] from optional `alignment`, `fit`, and a `children` list.
/// Non-Widget entries in `children` are silently filtered.
final class StackBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const StackBuilder();

  @override
  String get typeName => 'Stack';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final children = (args.get<List<Object?>>('children') ??
            const <Object?>[])
        .whereType<Widget>()
        .toList(growable: false);
    return Stack(
      alignment: args.getOr<AlignmentGeometry>(
        'alignment',
        AlignmentDirectional.topStart,
      ),
      fit: args.getOr<StackFit>('fit', StackFit.loose),
      children: children,
    );
  }
}

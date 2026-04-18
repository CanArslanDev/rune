import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [Row]. Mirrors [ColumnBuilder]'s children-filter behaviour —
/// non-Widget entries are silently dropped.
final class RowBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const RowBuilder();

  @override
  String get typeName => 'Row';

  /// Builds a [Row]. The `children` named argument is a `List<Object?>`
  /// whose non-[Widget] entries are silently filtered out. Axis-alignment
  /// arguments default to Flutter's own defaults when absent.
  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final children = (args.get<List<Object?>>('children') ??
            const <Object?>[])
        .whereType<Widget>()
        .toList(growable: false);
    return Row(
      mainAxisAlignment: args.getOr<MainAxisAlignment>(
        'mainAxisAlignment',
        MainAxisAlignment.start,
      ),
      crossAxisAlignment: args.getOr<CrossAxisAlignment>(
        'crossAxisAlignment',
        CrossAxisAlignment.center,
      ),
      mainAxisSize: args.getOr<MainAxisSize>(
        'mainAxisSize',
        MainAxisSize.max,
      ),
      children: children,
    );
  }
}

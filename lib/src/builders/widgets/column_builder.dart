import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [Column]. `children` is expected to be a `List<Object?>`;
/// non-Widget entries are silently filtered (rather than throwing) so
/// mixed-typed resolved lists don't explode at render time. Phase 2 adds
/// axis-alignment args once the ConstantRegistry lands.
final class ColumnBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const ColumnBuilder();

  @override
  String get typeName => 'Column';

  /// Builds a [Column]. The `children` named argument is a `List<Object?>`
  /// whose non-[Widget] entries are silently filtered out. Axis-alignment
  /// arguments default to Flutter's own defaults when absent.
  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final children = (args.get<List<Object?>>('children') ??
            const <Object?>[])
        .whereType<Widget>()
        .toList(growable: false);
    return Column(
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

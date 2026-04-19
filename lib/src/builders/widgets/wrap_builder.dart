import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [Wrap]. Lays out `children` along the chosen `direction` and
/// flows to the next line/column when space runs out.
///
/// Supported arguments: `direction` ([Axis], default [Axis.horizontal]),
/// `spacing` (num, coerced to double, default 0), `runSpacing` (num,
/// coerced to double, default 0), `alignment` ([WrapAlignment], default
/// [WrapAlignment.start]), `runAlignment` ([WrapAlignment], default
/// [WrapAlignment.start]), `crossAxisAlignment` ([WrapCrossAlignment],
/// default [WrapCrossAlignment.start]), `children` (a `List<Object?>`
/// whose non-[Widget] entries are silently filtered).
final class WrapBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const WrapBuilder();

  @override
  String get typeName => 'Wrap';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final children = (args.get<List<Object?>>('children') ??
            const <Object?>[])
        .whereType<Widget>()
        .toList(growable: false);
    return Wrap(
      direction: args.getOr<Axis>('direction', Axis.horizontal),
      spacing: args.get<num>('spacing')?.toDouble() ?? 0.0,
      runSpacing: args.get<num>('runSpacing')?.toDouble() ?? 0.0,
      alignment: args.getOr<WrapAlignment>(
        'alignment',
        WrapAlignment.start,
      ),
      runAlignment: args.getOr<WrapAlignment>(
        'runAlignment',
        WrapAlignment.start,
      ),
      crossAxisAlignment: args.getOr<WrapCrossAlignment>(
        'crossAxisAlignment',
        WrapCrossAlignment.start,
      ),
      children: children,
    );
  }
}

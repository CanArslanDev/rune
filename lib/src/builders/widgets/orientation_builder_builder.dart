import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/closure_builder_helpers.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [OrientationBuilder] with a
/// `(BuildContext, Orientation) => Widget` `RuneClosure`.
///
/// The builder closure is re-invoked when the ambient orientation
/// changes. The [Orientation] enum (`portrait`, `landscape`) is
/// registered under `registerPhase2aConstants`, so source can compare
/// the second arg against `Orientation.portrait` directly.
///
/// Required: `builder: (ctx, orientation) => Widget`.
final class OrientationBuilderBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const OrientationBuilderBuilder();

  @override
  String get typeName => 'OrientationBuilder';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final builder = toOrientationBuilder(
      args.named['builder'],
      'OrientationBuilder',
    );
    return OrientationBuilder(builder: builder);
  }
}

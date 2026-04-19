import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/closure_builder_helpers.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [FutureBuilder] bound to a host-provided [Future] value and a
/// `(BuildContext, AsyncSnapshot<Object?>) => Widget` `RuneClosure`.
///
/// Rune does not construct Futures from source; callers inject the
/// target Future via `RuneView.data` (e.g.
/// `data: {'myFuture': api.fetch()}`) and reference it by name in the
/// `future:` argument. The builder closure receives the live
/// [AsyncSnapshot] on every frame. Snapshot properties (`hasData`,
/// `.data`, `.hasError`, `.error`, `.connectionState`) are accessible
/// inside the closure via the built-in property whitelist.
///
/// Required: `builder: (ctx, snapshot) => Widget`.
/// Optional: `future: Future<Object?>?`, `initialData: Object?`.
///
/// The payload type is fixed at `Object?` because source has no
/// generic-type syntax; `snapshot.data` surfaces as `Object?` and the
/// closure body is free to narrow it (e.g. `snapshot.data.length`).
final class FutureBuilderBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const FutureBuilderBuilder();

  @override
  String get typeName => 'FutureBuilder';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final builder = toFutureSnapshotBuilder(
      args.named['builder'],
      'FutureBuilder',
    );
    return FutureBuilder<Object?>(
      future: args.get<Future<Object?>>('future'),
      initialData: args.named['initialData'],
      builder: builder,
    );
  }
}

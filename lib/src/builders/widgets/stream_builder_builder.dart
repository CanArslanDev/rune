import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/closure_builder_helpers.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [StreamBuilder] bound to a host-provided [Stream] and a
/// `(BuildContext, AsyncSnapshot<Object?>) => Widget` `RuneClosure`.
///
/// Identical shape to `FutureBuilderBuilder` but for continuous values.
/// Rune does not construct Streams from source; callers inject the
/// target Stream via `RuneView.data` and reference it by name.
///
/// Required: `builder: (ctx, snapshot) => Widget`.
/// Optional: `stream: Stream<Object?>?`, `initialData: Object?`.
final class StreamBuilderBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const StreamBuilderBuilder();

  @override
  String get typeName => 'StreamBuilder';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final builder = toStreamSnapshotBuilder(
      args.named['builder'],
      'StreamBuilder',
    );
    return StreamBuilder<Object?>(
      stream: args.get<Stream<Object?>>('stream'),
      initialData: args.named['initialData'],
      builder: builder,
    );
  }
}

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/stateful_builder_helpers.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';
import 'package:rune/src/core/rune_state.dart';

/// Builds a stateful region of source-level UI. The `initial` map
/// seeds a [RuneState] container on first mount; the `builder` closure
/// receives that state and returns the widget tree. Mutating the state
/// via `state.set(key, value)` triggers a rebuild.
///
/// ```
/// StatefulBuilder(
///   initial: {'counter': 0},
///   builder: (state) => Column(children: [
///     Text('Count: \${state.counter}'),
///     ElevatedButton(
///       onPressed: () => state.set('counter', state.counter + 1),
///       child: Text('Increment'),
///     ),
///   ]),
/// )
/// ```
///
/// Mutations made mid-build (e.g. inside the builder body) are
/// deferred to a post-frame callback so the hosting widget never
/// re-enters `setState` synchronously.
final class StatefulBuilderBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless; the mutable
  /// [RuneState] lives inside the private [State] object.
  const StatefulBuilderBuilder();

  @override
  String get typeName => 'StatefulBuilder';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final initialRaw = args.require<Map<Object?, Object?>>(
      'initial',
      source: 'StatefulBuilder',
    );
    final initial = initialRaw.map<String, Object?>(
      (k, v) => MapEntry(k.toString(), v),
    );
    final invokeBuilder = validateStatefulBuilderClosure(
      args.named['builder'],
    );
    return _StatefulHost(initial: initial, invokeBuilder: invokeBuilder);
  }
}

/// Private [StatefulWidget] that owns the [RuneState] and re-invokes
/// [invokeBuilder] on every frame.
class _StatefulHost extends StatefulWidget {
  const _StatefulHost({required this.initial, required this.invokeBuilder});

  final Map<String, Object?> initial;
  final Object? Function(RuneState state) invokeBuilder;

  @override
  State<_StatefulHost> createState() => _StatefulHostState();
}

class _StatefulHostState extends State<_StatefulHost> {
  late RuneState _state;

  @override
  void initState() {
    super.initState();
    _state = RuneState(
      entries: widget.initial,
      onMutation: _scheduleRebuild,
    );
  }

  void _scheduleRebuild() {
    // Defer setState if the mutation fires during a build phase (e.g.
    // inside the builder body). Otherwise call setState immediately so
    // the UI reflects the change on the next frame.
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.persistentCallbacks ||
        phase == SchedulerPhase.midFrameMicrotasks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
      return;
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.invokeBuilder(_state);
    if (result is! Widget) {
      throw ResolveException(
        'StatefulBuilder',
        'StatefulBuilder builder closure must return a Widget; '
        'got ${result.runtimeType}',
      );
    }
    return result;
  }
}

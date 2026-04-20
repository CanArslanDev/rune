import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/stateful_builder_helpers.dart';
import 'package:rune/src/core/animation_controller_spec.dart';
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
///
/// Optional lifecycle closures (all `(state) => ...`):
/// - `initState`: fires once after the state is seeded, before the
///   first build. Use to kick off controllers, start animations, etc.
/// - `dispose`: fires once on unmount, before auto-disposal runs.
/// - `didUpdateWidget`: fires when the enclosing `RuneView` rebuilds
///   this `_StatefulHost` in-place with new arguments.
///
/// Auto-disposal:
/// - `autoDisposeListenables: true` (default `false`) walks every
///   value in the initial state after the user `dispose` closure runs
///   and calls `.dispose()` on every entry that is a
///   [ChangeNotifier]. Non-Listenable entries are skipped.
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
    final invokeInitState = validateStatefulBuilderLifecycleClosure(
      args.named['initState'],
      paramName: 'initState',
    );
    final invokeDispose = validateStatefulBuilderLifecycleClosure(
      args.named['dispose'],
      paramName: 'dispose',
    );
    final invokeDidUpdateWidget = validateStatefulBuilderLifecycleClosure(
      args.named['didUpdateWidget'],
      paramName: 'didUpdateWidget',
    );
    final autoDisposeListenables = args.getOr<bool>(
      'autoDisposeListenables',
      false,
    );
    return _StatefulHost(
      initial: initial,
      invokeBuilder: invokeBuilder,
      invokeInitState: invokeInitState,
      invokeDispose: invokeDispose,
      invokeDidUpdateWidget: invokeDidUpdateWidget,
      autoDisposeListenables: autoDisposeListenables,
    );
  }
}

/// Private [StatefulWidget] that owns the [RuneState] and re-invokes
/// [invokeBuilder] on every frame.
class _StatefulHost extends StatefulWidget {
  const _StatefulHost({
    required this.initial,
    required this.invokeBuilder,
    required this.invokeInitState,
    required this.invokeDispose,
    required this.invokeDidUpdateWidget,
    required this.autoDisposeListenables,
  });

  final Map<String, Object?> initial;
  final Object? Function(RuneState state) invokeBuilder;
  final Object? Function(RuneState state)? invokeInitState;
  final Object? Function(RuneState state)? invokeDispose;
  final Object? Function(RuneState state)? invokeDidUpdateWidget;
  final bool autoDisposeListenables;

  @override
  State<_StatefulHost> createState() => _StatefulHostState();
}

class _StatefulHostState extends State<_StatefulHost>
    with TickerProviderStateMixin {
  late RuneState _state;

  /// Real `AnimationController` instances this host owns. Each entry was
  /// materialized from an [AnimationControllerSpec] found in
  /// `widget.initial`. The list exists so `dispose` can tear them down
  /// explicitly and `autoDisposeListenables` can skip them to avoid a
  /// double-dispose.
  final List<AnimationController> _ownedAnimationControllers =
      <AnimationController>[];

  @override
  void initState() {
    super.initState();
    _state = RuneState(
      entries: widget.initial,
      onMutation: _scheduleRebuild,
    );
    _materialiseAnimationControllers();
    widget.invokeInitState?.call(_state);
  }

  /// Walks the initial entries, replacing every [AnimationControllerSpec]
  /// with a freshly-constructed [AnimationController] bound to `this`
  /// as the [TickerProvider]. Mutates `_state.entries` directly to bypass
  /// the `onMutation` callback; materialization happens inside
  /// `initState` before the first build, so there is no rebuild to
  /// schedule. Disposal of the created controllers is handled in
  /// `dispose` via [_ownedAnimationControllers].
  void _materialiseAnimationControllers() {
    final entries = _state.entries;
    for (final key in entries.keys.toList()) {
      final v = entries[key];
      if (v is AnimationControllerSpec) {
        final ctrl = AnimationController(
          vsync: this,
          duration: v.duration,
          reverseDuration: v.reverseDuration,
          lowerBound: v.lowerBound,
          upperBound: v.upperBound,
          animationBehavior: v.animationBehavior,
          value: v.initialValue,
          debugLabel: v.debugLabel,
        );
        _ownedAnimationControllers.add(ctrl);
        // Direct mutation of the entries map does not fire onMutation,
        // which is the documented leaky-abstraction behavior of
        // RuneState.entries. We want this here: materialization runs
        // inside initState before any build, so scheduling a rebuild
        // would be wasted work.
        entries[key] = ctrl;
      }
    }
  }

  @override
  void didUpdateWidget(_StatefulHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.invokeDidUpdateWidget?.call(_state);
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
  void dispose() {
    // Run user dispose first so source-level cleanup sees the state
    // before any auto-disposed Listenables are torn down.
    widget.invokeDispose?.call(_state);
    // Dispose host-owned animation controllers explicitly. This runs
    // regardless of `autoDisposeListenables` because the host created
    // them implicitly from a spec; the source never saw the real
    // controller during resolution and therefore cannot be expected
    // to dispose it.
    for (final ctrl in _ownedAnimationControllers) {
      ctrl.dispose();
    }
    if (widget.autoDisposeListenables) {
      for (final entry in _state.entries.values) {
        if (entry is! ChangeNotifier) continue;
        // Skip entries already disposed above via the owned-controllers
        // list to prevent a double-dispose. Identity compare instead of
        // List.contains so the lint doesn't flag the unrelated-type
        // case (AnimationController vs ChangeNotifier).
        var alreadyDisposed = false;
        for (final owned in _ownedAnimationControllers) {
          if (identical(owned, entry)) {
            alreadyDisposed = true;
            break;
          }
        }
        if (alreadyDisposed) continue;
        entry.dispose();
      }
    }
    super.dispose();
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

import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:rune/src/binding/rune_data_context.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/binding/rune_inspector.dart';
import 'package:rune/src/config.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';
import 'package:rune/src/parser/ast_cache.dart';
import 'package:rune/src/parser/dart_parser.dart';
import 'package:rune/src/registry/component_registry.dart';
import 'package:rune/src/resolver/expression_resolver.dart';
import 'package:rune/src/resolver/identifier_resolver.dart';
import 'package:rune/src/resolver/invocation_resolver.dart';
import 'package:rune/src/resolver/literal_resolver.dart';
import 'package:rune/src/resolver/property_resolver.dart';

/// The public widget that turns a Dart widget-construction source string
/// into a live Flutter widget tree.
///
/// Callers supply a [source] and a [config]; optional [data] and [onEvent]
/// plumb runtime binding through [RuneContext]. Phase 1 wires them in but
/// no Phase-1 builder consumes them yet — data binding and button-event
/// dispatch land in Phase 2.
final class RuneView extends StatefulWidget {
  /// Constructs a [RuneView].
  const RuneView({
    required this.source,
    required this.config,
    this.data,
    this.onEvent,
    this.fallback,
    this.onError,
    super.key,
  });

  /// The Dart widget-construction source string to interpret.
  final String source;

  /// Configuration holding registered widget/value builders.
  final RuneConfig config;

  /// Flat map of runtime variables accessible from [source].
  final Map<String, Object?>? data;

  /// Callback invoked when the rendered tree dispatches a named event.
  final void Function(String event, [List<Object?>? args])? onEvent;

  /// Widget to display when parsing or resolution throws.
  final Widget? fallback;

  /// Error sink — receives both [RuneException]s and unexpected throwables.
  final void Function(Object error, StackTrace stack)? onError;

  @override
  State<RuneView> createState() => _RuneViewState();
}

class _RuneViewState extends State<RuneView> {
  late final DartParser _parser;
  late final AstCache _cache;
  late final ExpressionResolver _expr;
  late final InvocationResolver _invocation;
  RuneInspectorHandle? _inspectorHandle;
  Object? _lastError;

  @override
  void initState() {
    super.initState();
    _parser = DartParser();
    _cache = AstCache();
    _expr = ExpressionResolver(LiteralResolver(), IdentifierResolver());
    _invocation = InvocationResolver(_expr);
    _expr.bind(_invocation);
    final property = PropertyResolver(_expr);
    _expr.bindProperty(property);
    // Register for DevTools introspection. The inspector lazily wires
    // the `ext.rune.inspect` VM service extension on the first view;
    // release builds short-circuit to a no-op inside the inspector.
    _inspectorHandle = RuneInspector.instance.registerView(_inspectorSnapshot);
  }

  @override
  void dispose() {
    final handle = _inspectorHandle;
    if (handle != null) {
      RuneInspector.instance.unregisterView(handle);
    }
    super.dispose();
  }

  /// Builds a JSON-friendly snapshot of this view for the DevTools
  /// extension. Called on demand by the `ext.rune.inspect` VM service
  /// handler; never on the render path.
  Map<String, Object?> _inspectorSnapshot() {
    return <String, Object?>{
      'source': widget.source,
      'data': widget.data ?? const <String, Object?>{},
      'cacheSize': _cache.size,
      'lastError': _lastError?.toString(),
    };
  }

  @override
  Widget build(BuildContext context) {
    try {
      final ast = _parseOrCached(widget.source);
      final ctx = _buildContext(context);
      final result = _expr.resolve(ast, ctx);
      if (result is! Widget) {
        throw ResolveException(
          widget.source,
          'Root expression resolved to ${result.runtimeType}, not a Widget',
        );
      }
      return result;
    } catch (error, stack) {
      _lastError = error;
      widget.onError?.call(error, stack);
      return widget.fallback ?? _DefaultErrorView(error: error);
    }
  }

  Expression _parseOrCached(String source) {
    final cached = _cache.get(source);
    if (cached != null) return cached;
    final parsed = _parser.parse(source);
    _cache.put(source, parsed);
    return parsed;
  }

  @override
  void reassemble() {
    super.reassemble();
    // Hot-reload hook: clear the per-instance AST cache so source
    // edits in the host app's Dart code are re-parsed on the next
    // build. Without this override, a cached parsed AST would keep
    // serving the previous source.
    _cache.clear();
  }

  RuneContext _buildContext(BuildContext flutterCtx) {
    final events = RuneEventDispatcher();
    final onEvent = widget.onEvent;
    if (onEvent != null) {
      events.setCatchAllHandler(onEvent);
    }
    return RuneContext(
      widgets: widget.config.widgets,
      values: widget.config.values,
      data: RuneDataContext(widget.data ?? const <String, Object?>{}),
      events: events,
      constants: widget.config.constants,
      extensions: widget.config.extensions,
      components: ComponentRegistry(),
      imperatives: widget.config.imperatives,
      members: widget.config.members,
      source: widget.source,
      flutterContext: flutterCtx,
    );
  }
}

class _DefaultErrorView extends StatelessWidget {
  const _DefaultErrorView({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      return ErrorWidget(error);
    }
    return const SizedBox.shrink();
  }
}

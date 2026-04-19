import 'package:flutter/widgets.dart';
import 'package:rune/src/binding/rune_data_context.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/core/rune_scope.dart';
import 'package:rune/src/registry/component_registry.dart';
import 'package:rune/src/registry/constant_registry.dart';
import 'package:rune/src/registry/extension_registry.dart';
import 'package:rune/src/registry/value_registry.dart';
import 'package:rune/src/registry/widget_registry.dart';

/// The runtime context threaded through the resolve/build pipeline.
///
/// Every resolver and builder receives a [RuneContext] and reads:
/// - [widgets] / [values] to dispatch instance-creation expressions,
/// - [data] to resolve free identifiers (e.g. `Text(userName)`),
/// - [events] to wire named-event handlers (e.g. `onPressed: "submit"`),
/// - [constants] to resolve prefixed static constants (e.g. `Colors.red`),
/// - [extensions] to resolve property-access extensions (e.g. `10.w`),
/// - [flutterContext] to access `MediaQuery`, `Theme`, etc. when needed.
///
/// [flutterContext] is nullable because pure resolver/builder unit tests
/// never need it. Builders that require it should throw a
/// `ResolveException` when it is `null`.
///
/// The [@immutable] annotation guarantees every field of this class is
/// final — not that reachable state is deep-immutable. The registries
/// themselves (`widgets`, `values`, `constants`) remain mutable internally;
/// callers are expected to freeze their contents by convention.
@immutable
final class RuneContext {
  /// Constructs a [RuneContext] with the given registries, data, events,
  /// constants, and extensions.
  const RuneContext({
    required this.widgets,
    required this.values,
    required this.data,
    required this.events,
    required this.constants,
    required this.extensions,
    required this.components,
    required this.source,
    this.flutterContext,
    this.scope,
  });

  /// Registry of widget builders consulted by `InvocationResolver` when the
  /// resolved type corresponds to a Flutter widget.
  final WidgetRegistry widgets;

  /// Registry of value builders consulted for non-widget constructor calls
  /// (`EdgeInsets.all`, `TextStyle`, etc.).
  final ValueRegistry values;

  /// Runtime data bag referenced from the Rune source.
  final RuneDataContext data;

  /// Dispatcher for named events emitted from Rune-built widgets (e.g.
  /// `onPressed: "submit"`).
  final RuneEventDispatcher events;

  /// Registry of named static constants consulted by `IdentifierResolver`
  /// when resolving `PrefixedIdentifier` expressions like `Colors.red`.
  final ConstantRegistry constants;

  /// Registry of property-access extensions (e.g., `.w`, `.h`, `.px`)
  /// consulted by `PropertyResolver` when evaluating `PropertyAccess`
  /// expressions like `10.w`.
  final ExtensionRegistry extensions;

  /// Registry of named Rune components declared in the current source.
  ///
  /// Consulted by `InvocationResolver` ahead of the widget/value
  /// registries so a source-declared component (`RuneComponent(name:
  /// 'Foo', ...)`) shadows any default builder of the same name.
  /// Each `RuneView` render allocates a fresh [ComponentRegistry];
  /// components are not global.
  final ComponentRegistry components;

  /// The original Rune source string. Threaded through so resolvers can
  /// compute `SourceSpan` pointers from AST node offsets when raising
  /// exceptions. Empty string is a valid value for contexts constructed
  /// outside a `RuneView` render (e.g. unit tests that don't care about
  /// source-location-aware diagnostics).
  final String source;

  /// The enclosing Flutter `BuildContext`, used by builders that need
  /// `MediaQuery`, `Theme`, etc. `null` during non-widget-pumping unit
  /// tests where no real widget tree exists.
  final BuildContext? flutterContext;

  /// Mutable local scope threaded through block-body closure execution.
  ///
  /// `null` at top level (expressions outside a closure body); non-null
  /// inside a block-body closure call. Resolver arms consulting a
  /// `SimpleIdentifier` must check this scope *before* `data` so local
  /// declarations shadow host-provided data of the same name.
  final RuneScope? scope;

  /// Returns a copy of this context with any of the provided fields
  /// replaced.
  ///
  /// Limitation: passing an explicit `null` for [flutterContext] or
  /// [scope] will NOT clear the existing value (it is indistinguishable
  /// from passing no argument). Callers needing a null value should
  /// construct a new [RuneContext] directly. This is acceptable in Phase B
  /// because each block-body closure call sets a fresh non-null scope on
  /// top of the captured context; the context does not outlive the block.
  RuneContext copyWith({
    WidgetRegistry? widgets,
    ValueRegistry? values,
    RuneDataContext? data,
    RuneEventDispatcher? events,
    ConstantRegistry? constants,
    ExtensionRegistry? extensions,
    ComponentRegistry? components,
    String? source,
    BuildContext? flutterContext,
    RuneScope? scope,
  }) {
    return RuneContext(
      widgets: widgets ?? this.widgets,
      values: values ?? this.values,
      data: data ?? this.data,
      events: events ?? this.events,
      constants: constants ?? this.constants,
      extensions: extensions ?? this.extensions,
      components: components ?? this.components,
      source: source ?? this.source,
      flutterContext: flutterContext ?? this.flutterContext,
      scope: scope ?? this.scope,
    );
  }
}

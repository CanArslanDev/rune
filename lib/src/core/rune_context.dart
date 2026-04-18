import 'package:flutter/widgets.dart';
import 'package:rune/src/binding/rune_data_context.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/registry/value_registry.dart';
import 'package:rune/src/registry/widget_registry.dart';

/// The runtime context threaded through the resolve/build pipeline.
///
/// Every resolver and builder receives a [RuneContext] and reads:
/// - [widgets] / [values] to dispatch instance-creation expressions,
/// - [data] to resolve free identifiers (e.g. `Text(userName)`),
/// - [events] to wire named-event handlers (e.g. `onPressed: "submit"`),
/// - [flutterContext] to access `MediaQuery`, `Theme`, etc. when needed.
///
/// [flutterContext] is nullable because pure resolver/builder unit tests
/// never need it. Builders that require it should throw a
/// `ResolveException` when it is `null`.
@immutable
final class RuneContext {
  /// Constructs a [RuneContext] with the given registries, data, and events.
  const RuneContext({
    required this.widgets,
    required this.values,
    required this.data,
    required this.events,
    this.flutterContext,
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

  /// The enclosing Flutter `BuildContext`, used by builders that need
  /// `MediaQuery`, `Theme`, etc. `null` during non-widget-pumping unit
  /// tests where no real widget tree exists.
  final BuildContext? flutterContext;

  /// Returns a copy of this context with any of the provided fields
  /// replaced.
  RuneContext copyWith({
    WidgetRegistry? widgets,
    ValueRegistry? values,
    RuneDataContext? data,
    RuneEventDispatcher? events,
    BuildContext? flutterContext,
  }) {
    return RuneContext(
      widgets: widgets ?? this.widgets,
      values: values ?? this.values,
      data: data ?? this.data,
      events: events ?? this.events,
      flutterContext: flutterContext ?? this.flutterContext,
    );
  }
}

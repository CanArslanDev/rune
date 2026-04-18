import 'package:flutter/widgets.dart';
import 'package:rune/src/registry/value_registry.dart';
import 'package:rune/src/registry/widget_registry.dart';

/// The runtime context passed through the resolve/build pipeline.
///
/// Phase 1 minimal form — Task 10 expands this to include `DataContext` and
/// `EventDispatcher`. Do not rely on the signature being stable within
/// Phase 1.
@immutable
final class RuneContext {
  /// Creates a [RuneContext] with the required widget and value registries
  /// and an optional Flutter [BuildContext].
  const RuneContext({
    required this.widgets,
    required this.values,
    this.flutterContext,
  });

  /// Registry of widget builders consulted by `InvocationResolver` when the
  /// resolved type corresponds to a Flutter widget.
  final WidgetRegistry widgets;

  /// Registry of value builders consulted for non-widget constructor calls
  /// (`EdgeInsets.all`, `TextStyle`, etc.).
  final ValueRegistry values;

  /// The enclosing Flutter `BuildContext`, used by builders that need
  /// `MediaQuery`, `Theme`, etc. `null` during resolver unit tests where no
  /// real widget tree exists.
  final BuildContext? flutterContext;
}

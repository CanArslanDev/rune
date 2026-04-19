import 'package:flutter/widgets.dart';
import 'package:rune/src/binding/rune_data_context.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/core/rune_context.dart';
import 'package:rune/src/registry/constant_registry.dart';
import 'package:rune/src/registry/extension_registry.dart';
import 'package:rune/src/registry/value_registry.dart';
import 'package:rune/src/registry/widget_registry.dart';

/// Builds a [RuneContext] suitable for resolver/builder unit tests.
///
/// Callers can override any slot. Defaults: empty registries, empty data,
/// fresh [RuneEventDispatcher], empty [ConstantRegistry], empty
/// [ExtensionRegistry], empty [source] string, `flutterContext` null.
RuneContext testContext({
  WidgetRegistry? widgets,
  ValueRegistry? values,
  RuneDataContext? data,
  RuneEventDispatcher? events,
  ConstantRegistry? constants,
  ExtensionRegistry? extensions,
  String source = '',
  BuildContext? flutterContext,
}) {
  return RuneContext(
    widgets: widgets ?? WidgetRegistry(),
    values: values ?? ValueRegistry(),
    data: data ?? RuneDataContext.empty,
    events: events ?? RuneEventDispatcher(),
    constants: constants ?? ConstantRegistry(),
    extensions: extensions ?? ExtensionRegistry(),
    source: source,
    flutterContext: flutterContext,
  );
}

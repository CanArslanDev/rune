import 'package:flutter/widgets.dart';
import 'package:rune/rune.dart';

/// Builds a [RuneContext] suitable for builder-level unit tests in the
/// rune_router package.
RuneContext testContext({
  WidgetRegistry? widgets,
  ValueRegistry? values,
  RuneDataContext? data,
  RuneEventDispatcher? events,
  ConstantRegistry? constants,
  ExtensionRegistry? extensions,
  ComponentRegistry? components,
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
    components: components ?? ComponentRegistry(),
    source: source,
    flutterContext: flutterContext,
  );
}

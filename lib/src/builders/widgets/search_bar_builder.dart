import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/event_callback.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds Material 3 [SearchBar] - a standalone search input surface.
///
/// Source arguments:
/// - `hintText` ([String]?) - placeholder text while the bar is empty.
/// - `leading` ([Widget]?) - leading icon, typically a
///   `Icon(Icons.search)`.
/// - `trailing` (`List<Widget>?`) - trailing icons (clear button, etc.).
///   Non-[Widget] entries are silently filtered out.
/// - `controller` ([TextEditingController]?) - external controller for
///   programmatic read/write of the bar's text.
/// - `onChanged` (`String` event name or `RuneClosure` of arity 1) -
///   receives the current query string as its sole argument.
/// - `onTap` (`String` event name or `RuneClosure` of arity 0).
/// - `onSubmitted` (`String` event name or `RuneClosure` of arity 1).
/// - `elevation` ([num]? coerced to double).
final class SearchBarBuilder implements RuneWidgetBuilder {
  /// Const constructor - the builder is stateless.
  const SearchBarBuilder();

  @override
  String get typeName => 'SearchBar';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final rawTrailing = args.get<List<Object?>>('trailing');
    final trailing =
        rawTrailing?.whereType<Widget>().toList(growable: false);
    final elevation = args.get<num>('elevation')?.toDouble();
    return SearchBar(
      hintText: args.get<String>('hintText'),
      leading: args.get<Widget>('leading'),
      trailing: trailing,
      controller: args.get<TextEditingController>('controller'),
      onChanged: valueEventCallback<String>(
        args.named['onChanged'],
        ctx.events,
      ),
      onTap: voidEventCallback(args.named['onTap'], ctx.events),
      onSubmitted: valueEventCallback<String>(
        args.named['onSubmitted'],
        ctx.events,
      ),
      elevation: elevation == null
          ? null
          : WidgetStatePropertyAll<double>(elevation),
    );
  }
}

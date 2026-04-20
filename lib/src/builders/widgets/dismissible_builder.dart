import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/closure_builder_helpers.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [Dismissible]. Swipe-to-remove wrapper around a single
/// child. Flutter requires a [Key] on every [Dismissible]; the key
/// comes in from source as `key: ValueKey(...)` and must be pre-
/// resolved to a [Key] instance before the builder runs.
///
/// Required: `key`, `child`. The `key:` slot is resolver-owned in most
/// builders, but [Dismissible] is unique in treating its key as a
/// behavioral argument rather than a widget identity hint: list
/// removal semantics depend on it, so we read it from `args` and pass
/// it through explicitly.
///
/// Optional: `direction` ([DismissDirection], defaults to
/// `horizontal`), `background`, `onDismissed`.
final class DismissibleBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const DismissibleBuilder();

  @override
  String get typeName => 'Dismissible';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return Dismissible(
      key: args.require<Key>('key', source: 'Dismissible'),
      direction: args.getOr<DismissDirection>(
        'direction',
        DismissDirection.horizontal,
      ),
      background: args.get<Widget>('background'),
      onDismissed: toDismissibleCallback(
        args.named['onDismissed'],
        'Dismissible',
      ),
      child: args.require<Widget>('child', source: 'Dismissible'),
    );
  }
}

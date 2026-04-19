import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds a [ButtonSegment] of `Object?` - one entry inside a
/// [SegmentedButton]'s `segments:` list.
///
/// Source arguments:
/// - `value` ([Object?], required). The identity of this segment;
///   matched against [SegmentedButton.selected] entries.
/// - `label` ([Widget]?). Optional textual label.
/// - `icon` ([Widget]?). Optional leading icon.
/// - `tooltip` ([String]?).
/// - `enabled` ([bool]?). Defaults to `true`.
///
/// Typed on [Object?] because Rune source has no generics syntax; the
/// consuming [SegmentedButton] builder materialises a
/// `SegmentedButton<Object?>`.
final class ButtonSegmentBuilder implements RuneValueBuilder {
  /// Const constructor - the builder is stateless.
  const ButtonSegmentBuilder();

  @override
  String get typeName => 'ButtonSegment';

  @override
  String? get constructorName => null;

  @override
  ButtonSegment<Object?> build(ResolvedArguments args, RuneContext ctx) {
    if (!args.named.containsKey('value')) {
      // `value` may legitimately be null (nullable T), so we distinguish
      // absence from a stored-null via `containsKey` rather than
      // `require<T>` which rejects stored-nulls.
      throw const ArgumentException(
        'ButtonSegment',
        'Missing required argument "value" (may be null)',
      );
    }
    return ButtonSegment<Object?>(
      value: args.get<Object?>('value'),
      label: args.get<Widget>('label'),
      icon: args.get<Widget>('icon'),
      tooltip: args.get<String>('tooltip'),
      enabled: args.getOr<bool>('enabled', true),
    );
  }
}

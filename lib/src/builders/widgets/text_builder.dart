import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds [Text] widgets from a positional `String` and optional named
/// arguments (`style`, `textAlign`, `maxLines`, `overflow`).
final class TextBuilder implements RuneWidgetBuilder {
  /// Const constructor — the builder is stateless.
  const TextBuilder();

  @override
  String get typeName => 'Text';

  /// Builds a [Text] widget. Requires a `String` as the first positional
  /// argument; all other arguments are optional.
  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final data = args.requirePositional<String>(0, source: 'Text');
    return Text(
      data,
      style: args.get<TextStyle>('style'),
      textAlign: args.get<TextAlign>('textAlign'),
      maxLines: args.get<int>('maxLines'),
      overflow: args.get<TextOverflow>('overflow'),
    );
  }
}

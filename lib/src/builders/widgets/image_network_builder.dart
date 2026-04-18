import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds `Image.network(url)`. Registered as a [RuneValueBuilder] so it
/// can coexist with `Image.asset` under the shared type name — the
/// `ValueRegistry` disambiguates via constructor name.
final class ImageNetworkBuilder implements RuneValueBuilder {
  /// Const constructor — the builder is stateless.
  const ImageNetworkBuilder();

  @override
  String get typeName => 'Image';

  @override
  String? get constructorName => 'network';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final url = args.requirePositional<String>(0, source: 'Image.network');
    return Image.network(
      url,
      width: args.get<num>('width')?.toDouble(),
      height: args.get<num>('height')?.toDouble(),
      fit: args.get<BoxFit>('fit'),
    );
  }
}

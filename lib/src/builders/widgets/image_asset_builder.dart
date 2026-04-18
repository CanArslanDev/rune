import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds `Image.asset(path)`. Registered as a [RuneValueBuilder]
/// alongside `ImageNetworkBuilder` — they share `typeName == 'Image'`
/// and disambiguate via their distinct `constructorName`.
final class ImageAssetBuilder implements RuneValueBuilder {
  /// Const constructor — the builder is stateless.
  const ImageAssetBuilder();

  @override
  String get typeName => 'Image';

  @override
  String? get constructorName => 'asset';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final path = args.requirePositional<String>(0, source: 'Image.asset');
    return Image.asset(
      path,
      width: args.get<num>('width')?.toDouble(),
      height: args.get<num>('height')?.toDouble(),
      fit: args.get<BoxFit>('fit'),
    );
  }
}

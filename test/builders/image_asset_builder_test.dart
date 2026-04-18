import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/image_asset_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('ImageAssetBuilder', () {
    const b = ImageAssetBuilder();

    test('typeName/constructorName', () {
      expect(b.typeName, 'Image');
      expect(b.constructorName, 'asset');
    });

    test('builds Image.asset from positional path', () {
      final w = b.build(
        const ResolvedArguments(positional: ['assets/icon.png']),
        testContext(),
      );
      expect(w, isA<Image>());
      final image = w as Image;
      expect(image.image, isA<AssetImage>());
      expect((image.image as AssetImage).assetName, 'assets/icon.png');
    });

    test('applies width/height/fit', () {
      final w = b.build(
        const ResolvedArguments(
          positional: ['assets/icon.png'],
          named: {'width': 24, 'height': 24, 'fit': BoxFit.contain},
        ),
        testContext(),
      ) as Image;
      expect(w.width, 24.0);
      expect(w.height, 24.0);
      expect(w.fit, BoxFit.contain);
    });

    test('missing path throws ArgumentException', () {
      expect(
        () => b.build(const ResolvedArguments(), testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/image_network_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('ImageNetworkBuilder', () {
    const b = ImageNetworkBuilder();

    test('typeName/constructorName', () {
      expect(b.typeName, 'Image');
      expect(b.constructorName, 'network');
    });

    test('builds Image.network from positional URL', () {
      final w = b.build(
        const ResolvedArguments(positional: ['https://example.com/a.png']),
        testContext(),
      );
      expect(w, isA<Image>());
      final image = w as Image;
      expect(image.image, isA<NetworkImage>());
      expect(
        (image.image as NetworkImage).url,
        'https://example.com/a.png',
      );
    });

    test('applies width/height/fit', () {
      final w = b.build(
        const ResolvedArguments(
          positional: ['https://example.com/a.png'],
          named: {'width': 100, 'height': 50, 'fit': BoxFit.cover},
        ),
        testContext(),
      ) as Image;
      expect(w.width, 100.0);
      expect(w.height, 50.0);
      expect(w.fit, BoxFit.cover);
    });

    test('missing URL throws ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}

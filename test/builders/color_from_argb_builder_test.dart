import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/color_from_argb_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('ColorFromArgbBuilder', () {
    const b = ColorFromArgbBuilder();

    test('typeName/constructorName', () {
      expect(b.typeName, 'Color');
      expect(b.constructorName, 'fromARGB');
    });

    test('builds opaque red from four positional ints', () {
      final result = b.build(
        const ResolvedArguments(positional: [255, 255, 0, 0]),
        testContext(),
      );
      expect(result, const Color.fromARGB(255, 255, 0, 0));
    });

    test('half-alpha white round-trips', () {
      final result = b.build(
        const ResolvedArguments(positional: [128, 255, 255, 255]),
        testContext(),
      );
      expect(result, const Color.fromARGB(128, 255, 255, 255));
    });

    test('missing any positional throws ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(positional: [255, 255, 0]),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}

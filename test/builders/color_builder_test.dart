import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/color_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('ColorBuilder', () {
    const b = ColorBuilder();

    test('typeName/constructorName', () {
      expect(b.typeName, 'Color');
      expect(b.constructorName, isNull);
    });

    test('builds from a full-alpha hex int', () {
      final result = b.build(
        const ResolvedArguments(positional: [0xFFFF0000]),
        testContext(),
      );
      expect(result, const Color(0xFFFF0000));
    });

    test('builds from a partial-alpha hex int', () {
      final result = b.build(
        const ResolvedArguments(positional: [0x80FFFFFF]),
        testContext(),
      );
      expect(result, const Color(0x80FFFFFF));
    });

    test('missing positional throws ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}

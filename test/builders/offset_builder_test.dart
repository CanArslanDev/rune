import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/offset_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('OffsetBuilder', () {
    const b = OffsetBuilder();

    test('typeName/constructorName', () {
      expect(b.typeName, 'Offset');
      expect(b.constructorName, isNull);
    });

    test('Offset(10, 20) builds Offset(10.0, 20.0)', () {
      final o = b.build(
        const ResolvedArguments(positional: [10, 20]),
        testContext(),
      );
      expect(o, const Offset(10, 20));
      expect(o.dx, 10.0);
      expect(o.dy, 20.0);
    });

    test('missing first positional throws ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('missing second positional throws ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(positional: [10]),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}

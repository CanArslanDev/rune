import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/value_key_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('ValueKeyBuilder', () {
    const b = ValueKeyBuilder();

    test('typeName/constructorName', () {
      expect(b.typeName, 'ValueKey');
      expect(b.constructorName, isNull);
    });

    test('positional String builds ValueKey<Object>(value) with equality', () {
      final result = b.build(
        const ResolvedArguments(positional: ['id-42']),
        testContext(),
      );
      expect(result, isA<ValueKey<Object>>());
      expect(result, const ValueKey<Object>('id-42'));
    });

    test('positional int value round-trips via equality', () {
      final result = b.build(
        const ResolvedArguments(positional: [7]),
        testContext(),
      );
      expect(result, const ValueKey<Object>(7));
    });

    test('missing positional arg raises ArgumentException citing ValueKey',
        () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(
          isA<ArgumentException>()
              .having((e) => e.source, 'source', 'ValueKey'),
        ),
      );
    });

    test('explicit null positional arg raises ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(positional: [null]),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/date_time_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('DateTimeBuilder', () {
    const b = DateTimeBuilder();

    test('typeName/constructorName identify DateTime default ctor', () {
      expect(b.typeName, 'DateTime');
      expect(b.constructorName, isNull);
    });

    test('single positional year defaults month and day to 1', () {
      final d = b.build(
        const ResolvedArguments(positional: <Object?>[2026]),
        testContext(),
      );
      expect(d, DateTime(2026));
    });

    test('full year/month/day triple is honoured', () {
      final d = b.build(
        const ResolvedArguments(positional: <Object?>[2026, 4, 19]),
        testContext(),
      );
      expect(d, DateTime(2026, 4, 19));
    });

    test('year/month/day/hour/minute roundtrip', () {
      final d = b.build(
        const ResolvedArguments(positional: <Object?>[2026, 4, 19, 9, 30]),
        testContext(),
      );
      expect(d, DateTime(2026, 4, 19, 9, 30));
    });

    test(
      'missing year positional raises ArgumentException',
      () {
        expect(
          () => b.build(ResolvedArguments.empty, testContext()),
          throwsA(
            isA<ArgumentException>().having(
              (e) => e.source,
              'source',
              'DateTime',
            ),
          ),
        );
      },
    );
  });
}

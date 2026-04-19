import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/time_of_day_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('TimeOfDayBuilder', () {
    const b = TimeOfDayBuilder();

    test('typeName/constructorName identify TimeOfDay default ctor', () {
      expect(b.typeName, 'TimeOfDay');
      expect(b.constructorName, isNull);
    });

    test('constructs a valid time', () {
      final t = b.build(
        const ResolvedArguments(named: {'hour': 9, 'minute': 30}),
        testContext(),
      );
      expect(t, const TimeOfDay(hour: 9, minute: 30));
    });

    test('midnight roundtrips', () {
      final t = b.build(
        const ResolvedArguments(named: {'hour': 0, 'minute': 0}),
        testContext(),
      );
      expect(t.hour, 0);
      expect(t.minute, 0);
    });

    test(
      'missing hour raises ArgumentException citing TimeOfDay',
      () {
        expect(
          () => b.build(
            const ResolvedArguments(named: {'minute': 0}),
            testContext(),
          ),
          throwsA(
            isA<ArgumentException>().having(
              (e) => e.source,
              'source',
              'TimeOfDay',
            ),
          ),
        );
      },
    );

    test('missing minute raises ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(named: {'hour': 12}),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}

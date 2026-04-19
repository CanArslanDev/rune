import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/duration_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('DurationBuilder', () {
    const b = DurationBuilder();

    test('typeName/constructorName', () {
      expect(b.typeName, 'Duration');
      expect(b.constructorName, isNull);
    });

    test('no args builds Duration.zero', () {
      final result = b.build(ResolvedArguments.empty, testContext());
      expect(result, Duration.zero);
    });

    test('milliseconds: 500 builds 500ms', () {
      final result = b.build(
        const ResolvedArguments(named: {'milliseconds': 500}),
        testContext(),
      );
      expect(result, const Duration(milliseconds: 500));
    });

    test('combined seconds + milliseconds fields sum correctly', () {
      final result = b.build(
        const ResolvedArguments(
          named: {'seconds': 1, 'milliseconds': 500},
        ),
        testContext(),
      );
      expect(result, const Duration(milliseconds: 1500));
    });
  });
}

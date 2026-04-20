import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';
import 'package:rune_provider/src/widgets/consumer_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('ConsumerBuilder', () {
    const b = ConsumerBuilder();

    test('typeName is "Consumer"', () {
      expect(b.typeName, 'Consumer');
    });

    test('throws when builder is missing', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('throws when builder is not a closure', () {
      expect(
        () => b.build(
          const ResolvedArguments(named: {'builder': 'not a closure'}),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}

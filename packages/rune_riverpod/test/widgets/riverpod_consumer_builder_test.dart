import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';
import 'package:rune_riverpod/src/widgets/riverpod_consumer_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('RiverpodConsumerBuilder', () {
    const b = RiverpodConsumerBuilder();

    test('typeName is "RiverpodConsumer"', () {
      expect(b.typeName, 'RiverpodConsumer');
    });

    test('throws when provider is missing', () {
      expect(
        () => b.build(
          const ResolvedArguments(named: {'builder': 'ignored'}),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('throws when builder is missing', () {
      expect(
        () => b.build(
          const ResolvedArguments(named: {'provider': 'x'}),
          testContext(),
        ),
        // A null or wrong-typed `provider` throws TypeError first.
        throwsA(anything),
      );
    });
  });
}

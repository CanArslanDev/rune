import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';
import 'package:rune_bloc/src/widgets/bloc_builder_builder.dart';
import 'package:rune_bloc/src/widgets/bloc_listener_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('BlocBuilderBuilder', () {
    const b = BlocBuilderBuilder();

    test('typeName is "BlocBuilder"', () {
      expect(b.typeName, 'BlocBuilder');
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
          const ResolvedArguments(named: {'builder': 'nope'}),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });
  });

  group('BlocListenerBuilder', () {
    const b = BlocListenerBuilder();

    test('typeName is "BlocListener"', () {
      expect(b.typeName, 'BlocListener');
    });

    test('throws when listener is missing', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('throws when child is missing', () {
      expect(
        () => b.build(
          const ResolvedArguments(named: {'listener': 'nope'}),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}

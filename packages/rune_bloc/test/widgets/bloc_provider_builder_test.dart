import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';
import 'package:rune_bloc/src/widgets/bloc_provider_builder.dart';

import '../_helpers/test_context.dart';

class _CounterCubit extends Cubit<int> {
  _CounterCubit() : super(0);
  void increment() => emit(state + 1);
}

void main() {
  group('BlocProviderBuilder', () {
    const b = BlocProviderBuilder();

    test('typeName is "BlocProvider"', () {
      expect(b.typeName, 'BlocProvider');
    });

    test('throws when child is missing', () {
      expect(
        () => b.build(
          const ResolvedArguments(named: {'value': 0}),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('throws when both create and value are provided', () {
      final cubit = _CounterCubit();
      addTearDown(cubit.close);
      expect(
        () => b.build(
          ResolvedArguments(
            named: {
              'value': cubit,
              'create': 'ignored',
              'child': const SizedBox.shrink(),
            },
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('throws when neither create nor value is provided', () {
      expect(
        () => b.build(
          const ResolvedArguments(named: {'child': SizedBox.shrink()}),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('build with value returns a widget', () {
      final cubit = _CounterCubit();
      addTearDown(cubit.close);
      final widget = b.build(
        ResolvedArguments(
          named: {
            'value': cubit,
            'child': const SizedBox.shrink(),
          },
        ),
        testContext(),
      );
      expect(widget, isA<Widget>());
    });
  });
}

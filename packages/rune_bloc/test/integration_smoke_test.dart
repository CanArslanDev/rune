import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';
import 'package:rune_bloc/rune_bloc.dart';

class _CounterState implements RuneReactiveState {
  const _CounterState(this.count);
  final int count;

  @override
  Map<String, Object?> toRuneMap() => {'count': count};
}

class _CounterCubit extends Cubit<_CounterState> {
  _CounterCubit() : super(const _CounterState(0));
  void increment() => emit(_CounterState(state.count + 1));
}

RuneConfig _config() => RuneConfig.defaults().withBridges(const [BlocBridge()]);

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('BlocBridge integration through RuneView', () {
    testWidgets(
      'BlocProvider.value + BlocBuilder rebuild on emit',
      (tester) async {
        final cubit = _CounterCubit();
        addTearDown(cubit.close);

        await tester.pumpWidget(
          _wrap(
            RuneView(
              config: _config(),
              data: {'cubit': cubit},
              source: r'''
                BlocProvider(
                  value: cubit,
                  child: BlocBuilder(
                    builder: (ctx, state, child) => Text('count=${state.count}'),
                  ),
                )
              ''',
            ),
          ),
        );

        expect(find.text('count=0'), findsOneWidget);

        cubit.increment();
        await tester.pump();
        expect(find.text('count=1'), findsOneWidget);

        cubit.increment();
        await tester.pump();
        cubit.increment();
        await tester.pump();
        expect(find.text('count=3'), findsOneWidget);
      },
    );

    testWidgets(
      'BlocListener renders its child unchanged across state changes',
      (tester) async {
        // Source-level Dart-callable invocation is not supported, so
        // we verify BlocListener wiring by asserting that (a) the
        // `child` renders through the listener wrapper and (b) the
        // inner BlocBuilder continues to receive state updates even
        // while the BlocListener is in the tree.
        final cubit = _CounterCubit();
        addTearDown(cubit.close);

        await tester.pumpWidget(
          _wrap(
            RuneView(
              config: _config(),
              data: {'cubit': cubit},
              source: r'''
                BlocProvider(
                  value: cubit,
                  child: BlocListener(
                    listener: (ctx, state) => null,
                    child: BlocBuilder(
                      builder: (ctx, state, child) =>
                          Text('pair=${state.count}'),
                    ),
                  ),
                )
              ''',
            ),
          ),
        );

        expect(find.text('pair=0'), findsOneWidget);

        cubit.increment();
        await tester.pump();
        expect(find.text('pair=1'), findsOneWidget);
      },
    );
  });
}

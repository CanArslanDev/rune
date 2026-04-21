import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';
import 'package:rune_riverpod/rune_riverpod.dart';

final _counterProvider = StateProvider<int>((ref) => 0);

class _Counter implements RuneReactiveValue {
  const _Counter(this.count);
  final int count;

  @override
  Map<String, Object?> toRuneMap() => {'count': count};
}

final _counterObjectProvider = StateProvider<_Counter>(
  (ref) => const _Counter(0),
);

RuneConfig _config() =>
    RuneConfig.defaults().withBridges(const [RiverpodBridge()]);

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('RiverpodBridge integration through RuneView', () {
    testWidgets(
      'RiverpodConsumer renders and rebuilds on StateProvider<int> change',
      (tester) async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: _wrap(
              RuneView(
                config: _config(),
                data: {'counterProvider': _counterProvider},
                source: r'''
                  RiverpodConsumer(
                    provider: counterProvider,
                    builder: (ctx, count, child) => Text('n=$count'),
                  )
                ''',
              ),
            ),
          ),
        );

        expect(find.text('n=0'), findsOneWidget);

        container.read(_counterProvider.notifier).state = 5;
        await tester.pump();
        expect(find.text('n=5'), findsOneWidget);
      },
    );

    testWidgets(
      'RuneReactiveValue exposes fields for dot-access',
      (tester) async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: _wrap(
              RuneView(
                config: _config(),
                data: {'counterProvider': _counterObjectProvider},
                source: r'''
                  RiverpodConsumer(
                    provider: counterProvider,
                    builder: (ctx, state, child) => Text('n=${state.count}'),
                  )
                ''',
              ),
            ),
          ),
        );

        expect(find.text('n=0'), findsOneWidget);

        container.read(_counterObjectProvider.notifier).state =
            const _Counter(7);
        await tester.pump();
        expect(find.text('n=7'), findsOneWidget);
      },
    );

    testWidgets(
      'source-level ProviderScope mounts its own container',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            RuneView(
              config: _config(),
              data: {'counterProvider': _counterProvider},
              source: r'''
                ProviderScope(
                  child: RiverpodConsumer(
                    provider: counterProvider,
                    builder: (ctx, count, child) => Text('scoped=$count'),
                  ),
                )
              ''',
            ),
          ),
        );
        expect(find.text('scoped=0'), findsOneWidget);
      },
    );
  });
}

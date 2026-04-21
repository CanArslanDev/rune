// v0.2.0 integration: ChangeNotifiers that do NOT implement
// RuneReactiveNotifier reach source via MemberRegistry (v1.17+).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';
import 'package:rune_provider/rune_provider.dart';

class _PlainCounter extends ChangeNotifier {
  int _count = 0;
  int get count => _count;
  void increment() {
    _count += 1;
    notifyListeners();
  }
}

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group(
    'ProviderBridge v0.2.0 + MemberRegistry',
    () {
      testWidgets(
        'Consumer builder receives the raw notifier when it does not '
        'implement RuneReactiveNotifier, and MemberRegistry-registered '
        'properties are reachable via dot-access',
        (tester) async {
          final counter = _PlainCounter();
          addTearDown(counter.dispose);

          final config = RuneConfig.defaults()
              .withBridges(const [ProviderBridge()]);
          config.members.registerProperty<_PlainCounter>(
            'count',
            (c, _) => c.count,
          );

          await tester.pumpWidget(
            _wrap(
              RuneView(
                config: config,
                data: {'counter': counter},
                source: r'''
                  ChangeNotifierProvider(
                    value: counter,
                    child: Consumer(
                      builder: (ctx, c, child) => Text('n=${c.count}'),
                    ),
                  )
                ''',
              ),
            ),
          );

          expect(find.text('n=0'), findsOneWidget);

          counter.increment();
          await tester.pump();
          expect(find.text('n=1'), findsOneWidget);
        },
      );

      testWidgets(
        'Selector selector closure receives the raw notifier too',
        (tester) async {
          final counter = _PlainCounter();
          addTearDown(counter.dispose);

          final config = RuneConfig.defaults()
              .withBridges(const [ProviderBridge()]);
          config.members.registerProperty<_PlainCounter>(
            'count',
            (c, _) => c.count,
          );

          await tester.pumpWidget(
            _wrap(
              RuneView(
                config: config,
                data: {'counter': counter},
                source: r'''
                  ChangeNotifierProvider(
                    value: counter,
                    child: Selector(
                      selector: (ctx, c) => c.count,
                      builder: (ctx, n, child) => Text('sel=$n'),
                    ),
                  )
                ''',
              ),
            ),
          );

          expect(find.text('sel=0'), findsOneWidget);

          counter.increment();
          await tester.pump();
          expect(find.text('sel=1'), findsOneWidget);
        },
      );
    },
  );
}

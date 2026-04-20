import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';
import 'package:rune_provider/rune_provider.dart';

class _CounterNotifier extends ChangeNotifier
    implements RuneReactiveNotifier {
  int _count = 0;
  int get count => _count;
  void increment() {
    _count += 1;
    notifyListeners();
  }

  @override
  Map<String, Object?> get state => {'count': _count};
}

class _NameNotifier extends ChangeNotifier implements RuneReactiveNotifier {
  String _name = 'Ada';
  int _age = 30;
  String get name => _name;
  int get age => _age;

  void rename(String value) {
    _name = value;
    notifyListeners();
  }

  void bumpAge() {
    _age += 1;
    notifyListeners();
  }

  @override
  Map<String, Object?> get state => {'name': _name, 'age': _age};
}

RuneConfig _config() =>
    RuneConfig.defaults().withBridges(const [ProviderBridge()]);

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('ProviderBridge integration through RuneView', () {
    testWidgets(
      'ChangeNotifierProvider.value + Consumer rebuild on notifyListeners',
      (tester) async {
        final counter = _CounterNotifier();
        addTearDown(counter.dispose);

        await tester.pumpWidget(
          _wrap(
            RuneView(
              config: _config(),
              data: {'counter': counter},
              source: r'''
                ChangeNotifierProvider(
                  value: counter,
                  child: Consumer(
                    builder: (ctx, state, child) => Text('count=${state.count}'),
                  ),
                )
              ''',
            ),
          ),
        );

        expect(find.text('count=0'), findsOneWidget);

        counter.increment();
        await tester.pump();
        expect(find.text('count=1'), findsOneWidget);

        counter
          ..increment()
          ..increment();
        await tester.pump();
        expect(find.text('count=3'), findsOneWidget);
      },
    );

    testWidgets(
      'Selector rebuilds when the derived value changes, '
      'ignores unrelated notifyListeners',
      (tester) async {
        final notifier = _NameNotifier();
        addTearDown(notifier.dispose);

        await tester.pumpWidget(
          _wrap(
            RuneView(
              config: _config(),
              data: {'n': notifier},
              source: r'''
                ChangeNotifierProvider(
                  value: n,
                  child: Selector(
                    selector: (ctx, state) => state.name,
                    builder: (ctx, name, child) => Text('name=$name'),
                  ),
                )
              ''',
            ),
          ),
        );

        expect(find.text('name=Ada'), findsOneWidget);

        // Age bumps fire notifyListeners but do not change the
        // selector output. The rebuild is suppressed by provider's
        // Selector; the text stays the same.
        notifier.bumpAge();
        await tester.pump();
        expect(find.text('name=Ada'), findsOneWidget);

        // Name change flows through.
        notifier.rename('Grace');
        await tester.pump();
        expect(find.text('name=Grace'), findsOneWidget);
      },
    );

    testWidgets(
      'Consumer child: is forwarded untouched to builder as 3rd arg',
      (tester) async {
        final counter = _CounterNotifier();
        addTearDown(counter.dispose);

        await tester.pumpWidget(
          _wrap(
            RuneView(
              config: _config(),
              data: {'counter': counter},
              source: r'''
                ChangeNotifierProvider(
                  value: counter,
                  child: Consumer(
                    builder: (ctx, state, cachedChild) => Column(children: [
                      Text('count=${state.count}'),
                      cachedChild,
                    ]),
                    child: Text('cached'),
                  ),
                )
              ''',
            ),
          ),
        );

        expect(find.text('count=0'), findsOneWidget);
        expect(find.text('cached'), findsOneWidget);

        counter.increment();
        await tester.pump();
        expect(find.text('count=1'), findsOneWidget);
        expect(find.text('cached'), findsOneWidget);
      },
    );
  });
}

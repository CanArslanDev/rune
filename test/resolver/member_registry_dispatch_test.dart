import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';

class _CounterNotifier extends ChangeNotifier {
  int _count = 0;
  int get count => _count;
  bool get isZero => _count == 0;
  void increment() {
    _count += 1;
    notifyListeners();
  }

  void addN(int delta) {
    _count += delta;
    notifyListeners();
  }
}

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('MemberRegistry dispatch through RuneView', () {
    testWidgets(
      'registered property on a custom ChangeNotifier is readable from source',
      (tester) async {
        final counter = _CounterNotifier();
        addTearDown(counter.dispose);

        final config = RuneConfig.defaults();
        config.members
          ..registerProperty<_CounterNotifier>(
            'count',
            (t, _) => t.count,
          )
          ..registerProperty<_CounterNotifier>(
            'isZero',
            (t, _) => t.isZero,
          );

        Object? lastError;
        await tester.pumpWidget(
          _wrap(
            RuneView(
              config: config,
              data: {'counter': counter},
              source: r'''
                Column(children: [
                  Text('count=${counter.count}'),
                  if (counter.isZero) Text('empty'),
                ])
              ''',
              onError: (e, _) => lastError = e,
            ),
          ),
        );

        expect(lastError, isNull, reason: 'Render error: $lastError');
        expect(find.text('count=0'), findsOneWidget);
        expect(find.text('empty'), findsOneWidget);
      },
    );

    testWidgets(
      'registered method on a custom ChangeNotifier is callable from source',
      (tester) async {
        final counter = _CounterNotifier();
        addTearDown(counter.dispose);

        final config = RuneConfig.defaults();
        config.members
          ..registerProperty<_CounterNotifier>('count', (t, _) => t.count)
          ..registerMethod<_CounterNotifier>(
            'increment',
            (t, args, _) {
              t.increment();
              return null;
            },
          );

        Object? capturedError;
        await tester.pumpWidget(
          _wrap(
            RuneView(
              config: config,
              data: {'counter': counter},
              source: r'''
                ListenableBuilder(
                  listenable: counter,
                  builder: (ctx, child) => Column(children: [
                    Text('count=${counter.count}'),
                    ElevatedButton(
                      onPressed: () => counter.increment(),
                      child: Text('+'),
                    ),
                  ]),
                )
              ''',
              onError: (e, _) => capturedError = e,
            ),
          ),
        );

        expect(capturedError, isNull, reason: 'Render error: $capturedError');
        expect(find.text('count=0'), findsOneWidget);
        await tester.tap(find.text('+'));
        await tester.pump();
        expect(find.text('count=1'), findsOneWidget);
      },
    );

    testWidgets(
      'registered method receives positional args',
      (tester) async {
        final counter = _CounterNotifier();
        addTearDown(counter.dispose);

        final config = RuneConfig.defaults();
        config.members
          ..registerProperty<_CounterNotifier>('count', (t, _) => t.count)
          ..registerMethod<_CounterNotifier>(
            'addN',
            (t, args, _) {
              t.addN(args.first! as int);
              return null;
            },
          );

        await tester.pumpWidget(
          _wrap(
            RuneView(
              config: config,
              data: {'counter': counter},
              source: r'''
                ListenableBuilder(
                  listenable: counter,
                  builder: (ctx, child) => Column(children: [
                    Text('count=${counter.count}'),
                    ElevatedButton(
                      onPressed: () => counter.addN(5),
                      child: Text('+5'),
                    ),
                  ]),
                )
              ''',
            ),
          ),
        );

        expect(find.text('count=0'), findsOneWidget);
        await tester.tap(find.text('+5'));
        await tester.pump();
        expect(find.text('count=5'), findsOneWidget);
      },
    );

    testWidgets(
      'built-in whitelist still wins on stock types (String.length)',
      (tester) async {
        // Registering a name clash on String MUST NOT shadow the
        // built-in. The String is a recognized built-in type so the
        // MemberRegistry guard is bypassed entirely.
        final config = RuneConfig.defaults();
        config.members.registerProperty<String>(
          'length',
          (t, _) => -999,
        );

        await tester.pumpWidget(
          _wrap(
            RuneView(
              config: config,
              data: const {'name': 'hello'},
              source: r'''
                Text('${name.length}')
              ''',
            ),
          ),
        );

        expect(find.text('5'), findsOneWidget);
        expect(find.text('-999'), findsNothing);
      },
    );
  });
}

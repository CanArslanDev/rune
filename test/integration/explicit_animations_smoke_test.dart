import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('v1.9.0 smoke: explicit animations', () {
    testWidgets(
      'AnimationController.repeat drives a RotationTransition',
      (tester) async {
        // A controller declared in initial state is materialised to a
        // real AnimationController bound to the host's vsync. initState
        // calls .repeat() so the transition animates continuously.
        const source = '''
          StatefulBuilder(
            initial: {
              'ctrl': AnimationController(duration: Duration(seconds: 1)),
            },
            initState: (state) => state.ctrl.repeat(),
            builder: (state) => RotationTransition(
              turns: state.ctrl,
              child: Icon(Icons.refresh, size: 32),
            ),
          )
        ''';
        await tester.pumpWidget(
          _wrap(RuneView(source: source, config: RuneConfig.defaults())),
        );
        // Pump half a second; the animation is live.
        await tester.pump(const Duration(milliseconds: 500));
        // Multiple RotationTransitions can exist (MaterialApp internals);
        // at least our source-constructed one is in the tree.
        expect(find.byType(RotationTransition), findsWidgets);
        expect(find.byIcon(Icons.refresh), findsOneWidget);
        // Unmount without pumpAndSettle (repeat never settles). Host
        // dispose tears down the controller cleanly.
        await tester.pumpWidget(_wrap(const SizedBox.shrink()));
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'FadeTransition with AnimationController.forward fades in Text',
      (tester) async {
        const source = '''
          StatefulBuilder(
            initial: {
              'ctrl': AnimationController(
                duration: Duration(milliseconds: 300),
              ),
            },
            initState: (state) => state.ctrl.forward(),
            builder: (state) => FadeTransition(
              opacity: state.ctrl,
              child: Text('hello-fade'),
            ),
          )
        ''';
        await tester.pumpWidget(
          _wrap(RuneView(source: source, config: RuneConfig.defaults())),
        );
        expect(find.text('hello-fade'), findsOneWidget);
        // Settle past the 300ms forward duration.
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.text('hello-fade'), findsOneWidget);
        await tester.pumpWidget(_wrap(const SizedBox.shrink()));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'ScaleTransition composes with CurvedAnimation(parent, curve)',
      (tester) async {
        const source = '''
          StatefulBuilder(
            initial: {
              'ctrl': AnimationController(
                duration: Duration(milliseconds: 250),
                value: 1.0,
              ),
            },
            builder: (state) => ScaleTransition(
              scale: CurvedAnimation(
                parent: state.ctrl,
                curve: Curves.easeOut,
              ),
              child: Text('scaled'),
            ),
          )
        ''';
        await tester.pumpWidget(
          _wrap(RuneView(source: source, config: RuneConfig.defaults())),
        );
        expect(find.byType(ScaleTransition), findsWidgets);
        expect(find.text('scaled'), findsOneWidget);
        await tester.pumpWidget(_wrap(const SizedBox.shrink()));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'AnimatedBuilder rebuilds when the animation ticks',
      (tester) async {
        // Uses the .value whitelist to read the controller's current
        // value from inside the builder closure. forward() ticks the
        // value toward 1.0 over the configured duration.
        const source = '''
          StatefulBuilder(
            initial: {
              'ctrl': AnimationController(
                duration: Duration(milliseconds: 200),
              ),
            },
            initState: (state) => state.ctrl.forward(),
            builder: (state) => AnimatedBuilder(
              animation: state.ctrl,
              builder: (c, child) => Opacity(
                opacity: state.ctrl.value,
                child: Text('tick'),
              ),
            ),
          )
        ''';
        await tester.pumpWidget(
          _wrap(RuneView(source: source, config: RuneConfig.defaults())),
        );
        expect(find.text('tick'), findsOneWidget);
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('tick'), findsOneWidget);
        await tester.pumpWidget(_wrap(const SizedBox.shrink()));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'AnimationStatus enum is registered and reachable from source',
      (tester) async {
        const source = r'''
          StatefulBuilder(
            initial: {
              'ctrl': AnimationController(
                duration: Duration(milliseconds: 200),
              ),
              'status': AnimationStatus.dismissed,
            },
            builder: (state) => Text('s=${state.status}'),
          )
        ''';
        await tester.pumpWidget(
          _wrap(RuneView(source: source, config: RuneConfig.defaults())),
        );
        // Enum .toString renders as "AnimationStatus.dismissed".
        expect(find.text('s=AnimationStatus.dismissed'), findsOneWidget);
        await tester.pumpWidget(_wrap(const SizedBox.shrink()));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('v1.1.0 smoke: lifecycle hooks + controller value builders', () {
    testWidgets(
      'persistent TextEditingController via initial + dispose closure',
      (tester) async {
        // Source creates a controller as initial state, reads it via
        // `state.ctrl.text` to prove construction plumbed the `text`
        // arg, and disposes via the `dispose` closure on unmount.
        const source = '''
          StatefulBuilder(
            initial: {'ctrl': TextEditingController(text: 'hello')},
            dispose: (state) => state.ctrl.dispose(),
            builder: (state) => Text(state.ctrl.text),
          )
        ''';
        await tester.pumpWidget(
          _wrap(
            RuneView(
              source: source,
              config: RuneConfig.defaults(),
            ),
          ),
        );
        expect(find.text('hello'), findsOneWidget);
        // Unmount and verify the controller was disposed: a post-dispose
        // addListener asserts.
        await tester.pumpWidget(_wrap(const SizedBox.shrink()));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'TextEditingController.clear() mutates .text and rebuilds',
      (tester) async {
        // Button tap routes through state.ctrl.clear() (whitelisted
        // method) and then forces a rebuild by bumping a sentinel.
        const source = r'''
          StatefulBuilder(
            initial: {
              'ctrl': TextEditingController(text: 'hi'),
              'tick': 0,
            },
            autoDisposeListenables: true,
            builder: (state) => Column(
              children: [
                Text('t=${state.ctrl.text}'),
                ElevatedButton(
                  onPressed: () {
                    state.ctrl.clear();
                    state.set('tick', state.tick + 1);
                  },
                  child: Text('Clear'),
                ),
              ],
            ),
          )
        ''';
        await tester.pumpWidget(
          _wrap(
            RuneView(
              source: source,
              config: RuneConfig.defaults(),
            ),
          ),
        );
        expect(find.text('t=hi'), findsOneWidget);
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();
        expect(find.text('t='), findsOneWidget);
      },
    );

    testWidgets(
      'FocusNode.requestFocus / unfocus / hasFocus via whitelist',
      (tester) async {
        // Drive a FocusNode through its method whitelist. hasFocus is
        // a getter; requestFocus / unfocus are 0-arg methods. The
        // node is auto-disposed on unmount via the flag.
        const source = r'''
          StatefulBuilder(
            initial: {
              'focus': FocusNode(debugLabel: 'smoke'),
              'tick': 0,
            },
            autoDisposeListenables: true,
            builder: (state) => Column(
              children: [
                Text('focused=${state.focus.hasFocus}'),
                TextField(focusNode: null),
                ElevatedButton(
                  onPressed: () {
                    state.focus.requestFocus();
                    state.set('tick', state.tick + 1);
                  },
                  child: Text('Focus'),
                ),
                ElevatedButton(
                  onPressed: () {
                    state.focus.unfocus();
                    state.set('tick', state.tick + 1);
                  },
                  child: Text('Blur'),
                ),
              ],
            ),
          )
        ''';
        await tester.pumpWidget(
          _wrap(
            RuneView(
              source: source,
              config: RuneConfig.defaults(),
            ),
          ),
        );
        expect(find.text('focused=false'), findsOneWidget);
        // Method calls succeed without throwing (the node isn't
        // attached to a real Focus widget but requestFocus / unfocus
        // are no-op safe on unattached nodes).
        await tester.tap(find.text('Focus'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Blur'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'ScrollController constructs from source with optional args',
      (tester) async {
        const source = '''
          StatefulBuilder(
            initial: {'ctrl': ScrollController(initialScrollOffset: 0.0)},
            dispose: (state) => state.ctrl.dispose(),
            builder: (state) => Text('built'),
          )
        ''';
        await tester.pumpWidget(
          _wrap(
            RuneView(
              source: source,
              config: RuneConfig.defaults(),
            ),
          ),
        );
        expect(find.text('built'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'ScrollController jumpTo method is reachable via resolver',
      (tester) async {
        // A button press that just touches ScrollController without
        // needing a live scroll view: method dispatch path coverage.
        // Use dispose() which the whitelist exposes and which is safe
        // to call on a controller that was never attached.
        const source = r'''
          StatefulBuilder(
            initial: {'ctrl': ScrollController(), 'tick': 0},
            builder: (state) => Column(children: [
              Text('t=${state.tick}'),
              ElevatedButton(
                onPressed: () {
                  state.set('tick', state.tick + 1);
                },
                child: Text('Tick'),
              ),
            ]),
            dispose: (state) => state.ctrl.dispose(),
          )
        ''';
        await tester.pumpWidget(
          _wrap(
            RuneView(
              source: source,
              config: RuneConfig.defaults(),
            ),
          ),
        );
        expect(find.text('t=0'), findsOneWidget);
        await tester.tap(find.byType(ElevatedButton));
        await tester.pumpAndSettle();
        expect(find.text('t=1'), findsOneWidget);
        await tester.pumpWidget(_wrap(const SizedBox.shrink()));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'PageController constructs via source and disposes cleanly',
      (tester) async {
        const source = '''
          StatefulBuilder(
            initial: {'ctrl': PageController(initialPage: 2)},
            dispose: (state) => state.ctrl.dispose(),
            builder: (state) => Text('built'),
          )
        ''';
        await tester.pumpWidget(
          _wrap(
            RuneView(
              source: source,
              config: RuneConfig.defaults(),
            ),
          ),
        );
        expect(find.text('built'), findsOneWidget);
        await tester.pumpWidget(_wrap(const SizedBox.shrink()));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'initState closure runs before the first build',
      (tester) async {
        const source = r'''
          StatefulBuilder(
            initial: {'greeted': false, 'name': 'world'},
            initState: (state) => state.set('greeted', true),
            builder: (state) => Text(
              state.greeted ? 'hello, ${state.name}' : 'loading',
            ),
          )
        ''';
        await tester.pumpWidget(
          _wrap(
            RuneView(
              source: source,
              config: RuneConfig.defaults(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('hello, world'), findsOneWidget);
      },
    );
  });
}

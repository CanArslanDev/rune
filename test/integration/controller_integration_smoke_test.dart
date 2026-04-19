import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('v1.1.0 smoke: controller wiring on widgets', () {
    testWidgets(
      'TextField with source-owned controller round-trips text entry',
      (tester) async {
        const source = '''
          StatefulBuilder(
            initial: {'ctrl': TextEditingController(text: 'initial')},
            dispose: (state) => state.ctrl.dispose(),
            builder: (state) => TextField(controller: state.ctrl),
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
        // Initial seed from the source-owned controller flows to the field.
        expect(find.text('initial'), findsOneWidget);

        // Enter new text via the field; the source-owned controller must
        // observe the update (it IS the controller).
        await tester.enterText(find.byType(TextField), 'typed');
        await tester.pumpAndSettle();
        expect(find.text('typed'), findsOneWidget);

        // Unmount cleanly: the dispose closure drops the controller.
        await tester.pumpWidget(_wrap(const SizedBox.shrink()));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'ListView with source-owned ScrollController scrolls programmatically',
      (tester) async {
        const source = r'''
          StatefulBuilder(
            initial: {'ctrl': ScrollController()},
            dispose: (state) => state.ctrl.dispose(),
            builder: (state) => Column(
              children: [
                ElevatedButton(
                  onPressed: () => state.ctrl.jumpTo(200.0),
                  child: Text('Scroll'),
                ),
                SizedBox(
                  height: 100,
                  child: ListView(
                    controller: state.ctrl,
                    children: [
                      for (final i in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
                        SizedBox(height: 50, child: Text('row ${i}')),
                    ],
                  ),
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

        // ListView starts at offset 0.
        final scrollable = tester.widget<Scrollable>(
          find.byType(Scrollable).first,
        );
        expect(scrollable.controller?.offset, 0.0);

        // Tap the Scroll button: state.ctrl.jumpTo(200) runs through the
        // resolver's method whitelist and moves the ListView's offset.
        await tester.tap(find.text('Scroll'));
        await tester.pumpAndSettle();

        final scrollable2 = tester.widget<Scrollable>(
          find.byType(Scrollable).first,
        );
        expect(scrollable2.controller?.offset, greaterThan(0.0));

        await tester.pumpWidget(_wrap(const SizedBox.shrink()));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'TextField cleared via external controller from a button press',
      (tester) async {
        const source = '''
          StatefulBuilder(
            initial: {'ctrl': TextEditingController()},
            dispose: (state) => state.ctrl.dispose(),
            builder: (state) => Column(
              children: [
                TextField(controller: state.ctrl),
                ElevatedButton(
                  onPressed: () => state.ctrl.clear(),
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
        await tester.enterText(find.byType(TextField), 'hello there');
        await tester.pumpAndSettle();
        expect(find.text('hello there'), findsOneWidget);

        await tester.tap(find.text('Clear'));
        await tester.pumpAndSettle();
        // The external controller is the TextField's controller, so
        // clear() empties the rendered text.
        final tf = tester.widget<TextField>(find.byType(TextField));
        expect(tf.controller?.text, '');

        await tester.pumpWidget(_wrap(const SizedBox.shrink()));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  });
}

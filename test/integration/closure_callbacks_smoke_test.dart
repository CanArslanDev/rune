import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('Phase A.2 smoke: closures flow end-to-end through RuneView', () {
    testWidgets(
      'ElevatedButton with closure onPressed taps without throwing',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            RuneView(
              source:
                  "ElevatedButton(onPressed: () => 1, child: Text('tap'))",
              config: RuneConfig.defaults(),
            ),
          ),
        );
        // The button is enabled because the closure is non-null.
        final btn =
            tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(btn.onPressed, isNotNull);
        // Tapping invokes the closure body `1`; the value is discarded
        // (VoidCallback returns void). No exception should reach
        // `RuneView.onError`, so the widget keeps rendering.
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();
        expect(find.text('tap'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'ElevatedButton closure captures data map identifiers',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            RuneView(
              source: 'ElevatedButton('
                  'onPressed: () => counter, '
                  'child: Text(label))',
              config: RuneConfig.defaults(),
              data: const {'counter': 42, 'label': 'tap me'},
            ),
          ),
        );
        expect(find.text('tap me'), findsOneWidget);
        // Closure body `counter` resolves against the captured data
        // context. The returned value (42) is discarded by Flutter's
        // VoidCallback, but the resolve path must not throw.
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Switch with closure onChanged forwards the new bool into the closure',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            RuneView(
              source: 'Switch(value: isEnabled, onChanged: (v) => v)',
              config: RuneConfig.defaults(),
              data: const {'isEnabled': false},
            ),
          ),
        );
        // The switch renders enabled because onChanged is a non-null
        // closure.
        final sw = tester.widget<Switch>(find.byType(Switch));
        expect(sw.onChanged, isNotNull);
        expect(sw.value, isFalse);
        // Tap toggles the switch; Flutter invokes onChanged(true). The
        // closure body `v` resolves against the extended context
        // `{isEnabled: false, v: true}` to `true`, discarded by
        // ValueChanged's void return contract. No exception reaches the
        // widget's error path.
        await tester.tap(find.byType(Switch));
        await tester.pump();
        expect(tester.takeException(), isNull);
      },
    );
  });
}

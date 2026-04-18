import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/config.dart';
import 'package:rune/src/dynamic_view.dart';

Widget _wrap(Widget child) {
  return Directionality(textDirection: TextDirection.ltr, child: child);
}

void main() {
  group('RuneView', () {
    testWidgets('renders a single Text', (tester) async {
      await tester.pumpWidget(_wrap(RuneView(
        source: "Text('Hello Rune')",
        config: RuneConfig.defaults(),
      ),),);
      expect(find.text('Hello Rune'), findsOneWidget);
    });

    testWidgets('renders a Column of Texts', (tester) async {
      await tester.pumpWidget(_wrap(RuneView(
        source: "Column(children: [Text('a'), Text('b')])",
        config: RuneConfig.defaults(),
      ),),);
      expect(find.text('a'), findsOneWidget);
      expect(find.text('b'), findsOneWidget);
    });

    testWidgets('renders fallback on parse error', (tester) async {
      await tester.pumpWidget(_wrap(RuneView(
        source: 'Text(',
        config: RuneConfig.defaults(),
        fallback: const Text('FALLBACK'),
      ),),);
      expect(find.text('FALLBACK'), findsOneWidget);
    });

    testWidgets('invokes onError callback on failure', (tester) async {
      Object? captured;
      await tester.pumpWidget(_wrap(RuneView(
        source: 'Text(',
        config: RuneConfig.defaults(),
        fallback: const SizedBox.shrink(),
        onError: (error, stack) => captured = error,
      ),),);
      expect(captured, isNotNull);
    });

    testWidgets(
      'reassemble() is a no-op-safe hot-reload hook that re-renders',
      (tester) async {
        await tester.pumpWidget(_wrap(RuneView(
          source: "Text('before-reload')",
          config: RuneConfig.defaults(),
        ),),);
        expect(find.text('before-reload'), findsOneWidget);

        // Trigger Flutter's hot-reload lifecycle. The RuneView state
        // override clears the private AST cache so the next build
        // re-parses the source from scratch — internal state, not
        // observable here, so the test is a smoke-level assertion
        // that the call doesn't crash and the widget still renders.
        // ignore: invalid_use_of_protected_member
        tester.state<State<RuneView>>(find.byType(RuneView)).reassemble();
        await tester.pump();

        expect(find.text('before-reload'), findsOneWidget);
      },
    );
  });
}

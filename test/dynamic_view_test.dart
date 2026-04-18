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
  });
}

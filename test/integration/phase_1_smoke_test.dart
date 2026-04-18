import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';

Widget _wrap(Widget child) =>
    Directionality(textDirection: TextDirection.ltr, child: child);

void main() {
  group('Phase 1 end-to-end smoke tests', () {
    testWidgets('Text alone', (tester) async {
      await tester.pumpWidget(_wrap(RuneView(
        source: "Text('Hello')",
        config: RuneConfig.defaults(),
      ),),);
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('Column with two Texts (canonical MVP target)', (tester) async {
      await tester.pumpWidget(_wrap(RuneView(
        source: "Column(children: [Text('alpha'), Text('beta')])",
        config: RuneConfig.defaults(),
      ),),);
      expect(find.text('alpha'), findsOneWidget);
      expect(find.text('beta'), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('Row with SizedBox spacer between Texts', (tester) async {
      await tester.pumpWidget(_wrap(RuneView(
        source:
            "Row(children: [Text('L'), SizedBox(width: 20), Text('R')])",
        config: RuneConfig.defaults(),
      ),),);
      expect(find.text('L'), findsOneWidget);
      expect(find.text('R'), findsOneWidget);
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('Container with padding wrapping Text', (tester) async {
      await tester.pumpWidget(_wrap(RuneView(
        source:
            "Container(padding: EdgeInsets.all(8), child: Text('padded'))",
        config: RuneConfig.defaults(),
      ),),);
      expect(find.text('padded'), findsOneWidget);
      final container = tester.widget<Container>(find.byType(Container));
      expect(container.padding, const EdgeInsets.all(8));
    });

    testWidgets('Column of Containers (deeper nesting)', (tester) async {
      await tester.pumpWidget(_wrap(RuneView(
        source: """
          Column(children: [
            Container(padding: EdgeInsets.all(4), child: Text('a')),
            SizedBox(height: 8),
            Container(padding: EdgeInsets.all(4), child: Text('b')),
          ])
        """,
        config: RuneConfig.defaults(),
      ),),);
      expect(find.text('a'), findsOneWidget);
      expect(find.text('b'), findsOneWidget);
      expect(find.byType(Container), findsNWidgets(2));
    });

    testWidgets('unregistered type falls back', (tester) async {
      await tester.pumpWidget(_wrap(RuneView(
        source: 'NotAWidget()',
        config: RuneConfig.defaults(),
        fallback: const Text('ERR'),
      ),),);
      expect(find.text('ERR'), findsOneWidget);
    });
  });
}

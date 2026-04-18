import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';

void main() {
  group('RuneDevOverlay', () {
    testWidgets('passes through to child when not activated',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RuneDevOverlay(
              child: RuneView(
                source: "Text('hello')",
                config: RuneConfig.defaults(),
              ),
            ),
          ),
        ),
      );
      expect(find.text('hello'), findsOneWidget);
    });

    testWidgets('long-press opens the inspector bottom sheet',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RuneDevOverlay(
              sourceProvider: () => "Text('inspector-target')",
              child: RuneView(
                source: "Text('inspector-target')",
                config: RuneConfig.defaults(),
              ),
            ),
          ),
        ),
      );
      expect(find.text('inspector-target'), findsOneWidget);

      await tester.longPress(find.byType(RuneDevOverlay));
      await tester.pumpAndSettle();

      expect(find.text('Rune dev overlay'), findsOneWidget);
      expect(
        find.textContaining("Text('inspector-target')"),
        findsWidgets,
      );
    });

    testWidgets('closing the bottom sheet restores the child',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RuneDevOverlay(
              sourceProvider: () => "Text('closeable')",
              child: RuneView(
                source: "Text('closeable')",
                config: RuneConfig.defaults(),
              ),
            ),
          ),
        ),
      );
      await tester.longPress(find.byType(RuneDevOverlay));
      await tester.pumpAndSettle();
      expect(find.text('Rune dev overlay'), findsOneWidget);

      final ctx = tester.element(find.text('Rune dev overlay'));
      Navigator.of(ctx).pop();
      await tester.pumpAndSettle();

      expect(find.text('Rune dev overlay'), findsNothing);
      expect(find.text('closeable'), findsOneWidget);
    });
  });
}

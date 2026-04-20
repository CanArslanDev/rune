import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/interactive_viewer_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('InteractiveViewerBuilder', () {
    const b = InteractiveViewerBuilder();

    test('typeName is "InteractiveViewer"', () {
      expect(b.typeName, 'InteractiveViewer');
    });

    testWidgets('wraps child and defaults scale range to [0.8, 2.5]',
        (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {'child': Text('zoomable')},
        ),
        testContext(),
      );
      await tester.pumpWidget(_wrap(built));
      final w = tester.widget<InteractiveViewer>(
        find.byType(InteractiveViewer),
      );
      expect(w.minScale, 0.8);
      expect(w.maxScale, 2.5);
      expect(w.panEnabled, isTrue);
      expect(w.scaleEnabled, isTrue);
      expect(find.text('zoomable'), findsOneWidget);
    });

    test('missing child raises ArgumentException citing InteractiveViewer',
        () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(
          isA<ArgumentException>()
              .having((e) => e.source, 'source', 'InteractiveViewer'),
        ),
      );
    });

    testWidgets('scale overrides route through', (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {
            'child': Text('x'),
            'minScale': 0.5,
            'maxScale': 4.0,
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_wrap(built));
      final w = tester.widget<InteractiveViewer>(
        find.byType(InteractiveViewer),
      );
      expect(w.minScale, 0.5);
      expect(w.maxScale, 4.0);
    });

    testWidgets('panEnabled and scaleEnabled overrides route through',
        (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {
            'child': Text('x'),
            'panEnabled': false,
            'scaleEnabled': false,
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_wrap(built));
      final w = tester.widget<InteractiveViewer>(
        find.byType(InteractiveViewer),
      );
      expect(w.panEnabled, isFalse);
      expect(w.scaleEnabled, isFalse);
    });

    testWidgets('boundaryMargin override routes through', (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {
            'child': Text('x'),
            'boundaryMargin': EdgeInsets.all(42),
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_wrap(built));
      final w = tester.widget<InteractiveViewer>(
        find.byType(InteractiveViewer),
      );
      expect(w.boundaryMargin, const EdgeInsets.all(42));
    });
  });
}

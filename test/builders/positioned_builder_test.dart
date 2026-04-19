import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/positioned_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

Widget _stackHarness(Widget positioned) => MaterialApp(
      home: Scaffold(
        body: Stack(children: [positioned]),
      ),
    );

void main() {
  group('PositionedBuilder', () {
    const b = PositionedBuilder();

    test('typeName is "Positioned"', () {
      expect(b.typeName, 'Positioned');
    });

    testWidgets('left + top + child plumb through', (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {
            'left': 10,
            'top': 20,
            'child': Text('x'),
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_stackHarness(built));
      final w = tester.widget<Positioned>(find.byType(Positioned));
      expect(w.left, 10.0);
      expect(w.top, 20.0);
      expect(w.right, isNull);
      expect(w.bottom, isNull);
      expect(w.width, isNull);
      expect(w.height, isNull);
      expect(find.text('x'), findsOneWidget);
    });

    testWidgets('right + bottom + width + height plumb through',
        (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {
            'right': 5,
            'bottom': 5,
            'width': 50,
            'height': 50,
            'child': Text('y'),
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_stackHarness(built));
      final w = tester.widget<Positioned>(find.byType(Positioned));
      expect(w.right, 5.0);
      expect(w.bottom, 5.0);
      expect(w.width, 50.0);
      expect(w.height, 50.0);
      expect(find.text('y'), findsOneWidget);
    });

    test('missing child throws ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}

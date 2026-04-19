import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/animated_positioned_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

Widget _stackHarness(Widget positioned) => MaterialApp(
      home: Scaffold(
        body: Stack(children: [positioned]),
      ),
    );

void main() {
  group('AnimatedPositionedBuilder', () {
    const b = AnimatedPositionedBuilder();

    test('typeName is "AnimatedPositioned"', () {
      expect(b.typeName, 'AnimatedPositioned');
    });

    testWidgets('left + top + child + duration plumb through',
        (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {
            'left': 10,
            'top': 20,
            'duration': Duration(milliseconds: 300),
            'child': Text('x'),
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_stackHarness(built));
      final w = tester.widget<AnimatedPositioned>(
        find.byType(AnimatedPositioned),
      );
      expect(w.left, 10.0);
      expect(w.top, 20.0);
      expect(w.right, isNull);
      expect(w.bottom, isNull);
      expect(w.duration, const Duration(milliseconds: 300));
      expect(find.text('x'), findsOneWidget);
    });

    testWidgets(
        'curve defaults to Curves.linear; explicit curve plumbs through',
        (tester) async {
      final builtDefault = b.build(
        const ResolvedArguments(
          named: {
            'duration': Duration(milliseconds: 100),
            'child': Text('a'),
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_stackHarness(builtDefault));
      final wd = tester.widget<AnimatedPositioned>(
        find.byType(AnimatedPositioned),
      );
      expect(wd.curve, same(Curves.linear));

      final builtExplicit = b.build(
        const ResolvedArguments(
          named: {
            'duration': Duration(milliseconds: 100),
            'curve': Curves.easeInOut,
            'child': Text('b'),
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_stackHarness(builtExplicit));
      final we = tester.widget<AnimatedPositioned>(
        find.byType(AnimatedPositioned),
      );
      expect(we.curve, same(Curves.easeInOut));
    });

    test('missing duration throws ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(named: {'child': Text('x')}),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('missing child throws ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(
            named: {'duration': Duration(milliseconds: 100)},
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}

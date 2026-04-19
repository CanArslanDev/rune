import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/grid_view_count_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

Widget _harness(Widget built) => MaterialApp(
      home: Scaffold(
        body: SizedBox(width: 400, height: 400, child: built),
      ),
    );

void main() {
  group('GridViewCountBuilder', () {
    const b = GridViewCountBuilder();

    test('typeName/constructorName', () {
      expect(b.typeName, 'GridView');
      expect(b.constructorName, 'count');
    });

    testWidgets('builds a 2-column GridView with children', (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {
            'crossAxisCount': 2,
            'children': <Object?>[
              Text('a'),
              Text('b'),
              Text('c'),
              Text('d'),
            ],
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      expect(find.byType(GridView), findsOneWidget);
      expect(find.text('a'), findsOneWidget);
      expect(find.text('b'), findsOneWidget);
      expect(find.text('c'), findsOneWidget);
      expect(find.text('d'), findsOneWidget);
    });

    test('missing crossAxisCount throws ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });

    testWidgets(
        'mainAxisSpacing + crossAxisSpacing + childAspectRatio plumb through',
        (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {
            'crossAxisCount': 3,
            'mainAxisSpacing': 8,
            'crossAxisSpacing': 12,
            'childAspectRatio': 1.5,
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      final w = tester.widget<GridView>(find.byType(GridView));
      final delegate =
          w.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, 3);
      expect(delegate.mainAxisSpacing, 8.0);
      expect(delegate.crossAxisSpacing, 12.0);
      expect(delegate.childAspectRatio, 1.5);
    });

    testWidgets('scrollDirection horizontal plumbs through', (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {
            'crossAxisCount': 2,
            'scrollDirection': Axis.horizontal,
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      final w = tester.widget<GridView>(find.byType(GridView));
      expect(w.scrollDirection, Axis.horizontal);
    });

    testWidgets('padding + shrinkWrap + reverse plumb through',
        (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {
            'crossAxisCount': 2,
            'padding': EdgeInsets.all(16),
            'shrinkWrap': true,
            'reverse': true,
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      final w = tester.widget<GridView>(find.byType(GridView));
      expect(w.padding, const EdgeInsets.all(16));
      expect(w.shrinkWrap, isTrue);
      expect(w.reverse, isTrue);
    });
  });
}

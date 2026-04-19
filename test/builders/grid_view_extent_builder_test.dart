import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/grid_view_extent_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

Widget _harness(Widget built) => MaterialApp(
      home: Scaffold(
        body: SizedBox(width: 400, height: 400, child: built),
      ),
    );

void main() {
  group('GridViewExtentBuilder', () {
    const b = GridViewExtentBuilder();

    test('typeName/constructorName', () {
      expect(b.typeName, 'GridView');
      expect(b.constructorName, 'extent');
    });

    testWidgets('builds a GridView.extent with children', (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {
            'maxCrossAxisExtent': 100,
            'children': <Object?>[
              Text('a'),
              Text('b'),
            ],
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      expect(find.byType(GridView), findsOneWidget);
      expect(find.text('a'), findsOneWidget);
      expect(find.text('b'), findsOneWidget);
    });

    test('missing maxCrossAxisExtent throws ArgumentException', () {
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
            'maxCrossAxisExtent': 120,
            'mainAxisSpacing': 6,
            'crossAxisSpacing': 10,
            'childAspectRatio': 2.0,
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      final w = tester.widget<GridView>(find.byType(GridView));
      final delegate =
          w.gridDelegate as SliverGridDelegateWithMaxCrossAxisExtent;
      expect(delegate.maxCrossAxisExtent, 120.0);
      expect(delegate.mainAxisSpacing, 6.0);
      expect(delegate.crossAxisSpacing, 10.0);
      expect(delegate.childAspectRatio, 2.0);
    });

    testWidgets(
        'scrollDirection horizontal + shrinkWrap + padding plumb through',
        (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {
            'maxCrossAxisExtent': 80,
            'scrollDirection': Axis.horizontal,
            'shrinkWrap': true,
            'padding': EdgeInsets.all(8),
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      final w = tester.widget<GridView>(find.byType(GridView));
      expect(w.scrollDirection, Axis.horizontal);
      expect(w.shrinkWrap, isTrue);
      expect(w.padding, const EdgeInsets.all(8));
    });
  });
}

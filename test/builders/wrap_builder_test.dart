import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/wrap_builder.dart';

import '../_helpers/test_context.dart';

Widget _harness(Widget built) => MaterialApp(home: Scaffold(body: built));

void main() {
  group('WrapBuilder', () {
    const b = WrapBuilder();

    test('typeName is "Wrap"', () {
      expect(b.typeName, 'Wrap');
    });

    testWidgets('no children renders an empty Wrap', (tester) async {
      final built = b.build(
        ResolvedArguments.empty,
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      final w = tester.widget<Wrap>(find.byType(Wrap));
      expect(w.children, isEmpty);
      expect(w.direction, Axis.horizontal);
      expect(w.spacing, 0.0);
      expect(w.runSpacing, 0.0);
      expect(w.alignment, WrapAlignment.start);
      expect(w.runAlignment, WrapAlignment.start);
      expect(w.crossAxisAlignment, WrapCrossAlignment.start);
    });

    testWidgets('children plumb through', (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {
            'children': <Object?>[
              Text('a'),
              Text('b'),
              Text('c'),
            ],
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      expect(find.text('a'), findsOneWidget);
      expect(find.text('b'), findsOneWidget);
      expect(find.text('c'), findsOneWidget);
      final w = tester.widget<Wrap>(find.byType(Wrap));
      expect(w.children, hasLength(3));
    });

    testWidgets('spacing and runSpacing plumb through', (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {
            'spacing': 8,
            'runSpacing': 4,
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      final w = tester.widget<Wrap>(find.byType(Wrap));
      expect(w.spacing, 8.0);
      expect(w.runSpacing, 4.0);
    });

    testWidgets('direction + alignment + crossAxisAlignment plumb through',
        (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {
            'direction': Axis.vertical,
            'alignment': WrapAlignment.center,
            'runAlignment': WrapAlignment.spaceBetween,
            'crossAxisAlignment': WrapCrossAlignment.center,
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      final w = tester.widget<Wrap>(find.byType(Wrap));
      expect(w.direction, Axis.vertical);
      expect(w.alignment, WrapAlignment.center);
      expect(w.runAlignment, WrapAlignment.spaceBetween);
      expect(w.crossAxisAlignment, WrapCrossAlignment.center);
    });

    testWidgets('filters non-Widget children silently', (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {
            'children': <Object?>[
              Text('keep'),
              42,
              'skip',
              Text('also-keep'),
            ],
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      final w = tester.widget<Wrap>(find.byType(Wrap));
      expect(w.children, hasLength(2));
      expect(find.text('keep'), findsOneWidget);
      expect(find.text('also-keep'), findsOneWidget);
    });
  });
}

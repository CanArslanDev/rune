import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/badge_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('BadgeBuilder', () {
    const b = BadgeBuilder();

    test('typeName is "Badge"', () {
      expect(b.typeName, 'Badge');
    });

    testWidgets('renders label and child', (tester) async {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'label': Text('3'),
            'child': Icon(Icons.notifications),
          },
        ),
        testContext(),
      );

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: w)),
      );
      expect(find.text('3'), findsOneWidget);
      expect(find.byIcon(Icons.notifications), findsOneWidget);
    });

    test('backgroundColor and textColor plumb through', () {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'label': Text('9'),
            'backgroundColor': Color(0xFFFF0000),
            'textColor': Color(0xFFFFFFFF),
          },
        ),
        testContext(),
      ) as Badge;
      expect(w.backgroundColor, const Color(0xFFFF0000));
      expect(w.textColor, const Color(0xFFFFFFFF));
    });

    test('isLabelVisible defaults true and plumbs false', () {
      final defaultW = b.build(
        const ResolvedArguments(named: {'label': Text('1')}),
        testContext(),
      ) as Badge;
      expect(defaultW.isLabelVisible, isTrue);

      final hidden = b.build(
        const ResolvedArguments(
          named: {'label': Text('1'), 'isLabelVisible': false},
        ),
        testContext(),
      ) as Badge;
      expect(hidden.isLabelVisible, isFalse);
    });
  });
}

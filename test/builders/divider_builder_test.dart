import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/divider_builder.dart';

import '../_helpers/test_context.dart';

Widget _harness(Widget built) => MaterialApp(home: Scaffold(body: built));

void main() {
  group('DividerBuilder', () {
    const b = DividerBuilder();

    test('typeName is "Divider"', () {
      expect(b.typeName, 'Divider');
    });

    testWidgets('no-args renders a Divider with Flutter defaults',
        (tester) async {
      final built = b.build(ResolvedArguments.empty, testContext());
      await tester.pumpWidget(_harness(built));
      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('height, thickness, indent, endIndent, color plumb through',
        (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {
            'height': 8.0,
            'thickness': 2.0,
            'indent': 16.0,
            'endIndent': 16.0,
            'color': Color(0xFFFF0000),
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      final d = tester.widget<Divider>(find.byType(Divider));
      expect(d.height, 8.0);
      expect(d.thickness, 2.0);
      expect(d.indent, 16.0);
      expect(d.endIndent, 16.0);
      expect(d.color, const Color(0xFFFF0000));
    });

    testWidgets('int numeric values are coerced to double', (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {
            'height': 8,
            'thickness': 2,
            'indent': 16,
            'endIndent': 16,
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      final d = tester.widget<Divider>(find.byType(Divider));
      expect(d.height, 8.0);
      expect(d.thickness, 2.0);
      expect(d.indent, 16.0);
      expect(d.endIndent, 16.0);
    });
  });
}

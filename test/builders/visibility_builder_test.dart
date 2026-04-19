import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/visibility_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

Widget _harness(Widget built) => MaterialApp(home: Scaffold(body: built));

void main() {
  group('VisibilityBuilder', () {
    const b = VisibilityBuilder();

    test('typeName is "Visibility"', () {
      expect(b.typeName, 'Visibility');
    });

    testWidgets('visible: true renders the child', (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {'visible': true, 'child': Text('x')},
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      expect(find.text('x'), findsOneWidget);
    });

    testWidgets('visible: false hides the child (default replacement)',
        (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {'visible': false, 'child': Text('x')},
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      expect(find.text('x'), findsNothing);
    });

    testWidgets('visible: false + custom replacement shows replacement',
        (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {
            'visible': false,
            'child': Text('visible-child'),
            'replacement': Text('hidden'),
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      expect(find.text('visible-child'), findsNothing);
      expect(find.text('hidden'), findsOneWidget);
    });

    test('missing child throws ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}

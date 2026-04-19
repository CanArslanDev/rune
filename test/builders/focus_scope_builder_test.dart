import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/focus_scope_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('FocusScopeBuilder', () {
    const b = FocusScopeBuilder();

    test('typeName is "FocusScope"', () {
      expect(b.typeName, 'FocusScope');
    });

    test('missing child raises ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });

    testWidgets('wraps the child in a FocusScope', (tester) async {
      final built = b.build(
        const ResolvedArguments(named: {'child': Text('x')}),
        testContext(),
      );
      await tester.pumpWidget(
        Directionality(textDirection: TextDirection.ltr, child: built),
      );
      expect(find.byType(FocusScope), findsWidgets);
      expect(find.text('x'), findsOneWidget);
    });

    testWidgets('autofocus grants focus to a nested autofocus Focus',
        (tester) async {
      final inner = FocusNode();
      addTearDown(inner.dispose);
      final built = b.build(
        ResolvedArguments(
          named: {
            'autofocus': true,
            'child': Focus(
              focusNode: inner,
              autofocus: true,
              child: const SizedBox(width: 10, height: 10),
            ),
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(
        Directionality(textDirection: TextDirection.ltr, child: built),
      );
      await tester.pump();
      expect(inner.hasFocus, isTrue);
    });

    testWidgets('nested requestFocus resolves through the scope',
        (tester) async {
      final inner = FocusNode();
      addTearDown(inner.dispose);
      final built = b.build(
        ResolvedArguments(
          named: {
            'child': Focus(
              focusNode: inner,
              child: const SizedBox(width: 10, height: 10),
            ),
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(
        Directionality(textDirection: TextDirection.ltr, child: built),
      );
      inner.requestFocus();
      await tester.pump();
      expect(inner.hasFocus, isTrue);
    });

    testWidgets('renders child subtree by default (no autofocus, no errors)',
        (tester) async {
      final built = b.build(
        const ResolvedArguments(named: {'child': Text('child-inside')}),
        testContext(),
      );
      await tester.pumpWidget(
        Directionality(textDirection: TextDirection.ltr, child: built),
      );
      expect(find.text('child-inside'), findsOneWidget);
    });
  });
}

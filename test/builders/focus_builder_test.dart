import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/focus_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('FocusBuilder', () {
    const b = FocusBuilder();

    test('typeName is "Focus"', () {
      expect(b.typeName, 'Focus');
    });

    test('missing child raises ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });

    testWidgets('wraps the child in a Focus and renders the subtree',
        (tester) async {
      final built = b.build(
        const ResolvedArguments(named: {'child': Text('x')}),
        testContext(),
      );
      await tester.pumpWidget(
        Directionality(textDirection: TextDirection.ltr, child: built),
      );
      expect(find.byType(Focus), findsWidgets);
      expect(find.text('x'), findsOneWidget);
    });

    testWidgets('external focusNode is attached and can requestFocus',
        (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      final built = b.build(
        ResolvedArguments(
          named: {
            'child': const SizedBox(width: 10, height: 10),
            'focusNode': node,
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(
        Directionality(textDirection: TextDirection.ltr, child: built),
      );
      node.requestFocus();
      await tester.pump();
      expect(node.hasFocus, isTrue);
    });

    testWidgets('autofocus grants focus on first mount', (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      final built = b.build(
        ResolvedArguments(
          named: {
            'child': const SizedBox(width: 10, height: 10),
            'focusNode': node,
            'autofocus': true,
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(
        Directionality(textDirection: TextDirection.ltr, child: built),
      );
      await tester.pump();
      expect(node.hasFocus, isTrue);
    });

    testWidgets('canRequestFocus: false blocks focus acquisition',
        (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      final built = b.build(
        ResolvedArguments(
          named: {
            'child': const SizedBox(width: 10, height: 10),
            'focusNode': node,
            'canRequestFocus': false,
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(
        Directionality(textDirection: TextDirection.ltr, child: built),
      );
      node.requestFocus();
      await tester.pump();
      expect(node.hasFocus, isFalse);
    });
  });
}

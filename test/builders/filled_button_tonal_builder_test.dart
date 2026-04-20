import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/filled_button_tonal_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('FilledButtonTonalBuilder', () {
    const b = FilledButtonTonalBuilder();

    test('typeName is "FilledButton"', () {
      expect(b.typeName, 'FilledButton');
    });

    test('constructorName is "tonal"', () {
      expect(b.constructorName, 'tonal');
    });

    test('default: no args yields a disabled FilledButton', () {
      final w = b.build(ResolvedArguments.empty, testContext())
          as FilledButton;
      expect(w.onPressed, isNull);
    });

    test('onPressed String event wires through ctx.events', () {
      final events = <String>[];
      final ctx = testContext()
        ..events.register('tap', () => events.add('fired'));
      final w = b.build(
        const ResolvedArguments(named: {'onPressed': 'tap'}),
        ctx,
      ) as FilledButton;
      w.onPressed!();
      expect(events, <String>['fired']);
    });

    testWidgets('renders the provided child', (tester) async {
      final w = b.build(
        const ResolvedArguments(
          named: {'child': Text('Tonal'), 'onPressed': 'tap'},
        ),
        testContext(),
      );
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: w)),
      );
      expect(find.text('Tonal'), findsOneWidget);
    });

    testWidgets('null child falls back to SizedBox.shrink', (tester) async {
      final w = b.build(
        const ResolvedArguments(named: {'onPressed': 'tap'}),
        testContext(),
      ) as FilledButton;
      expect(w.child, isA<SizedBox>());
    });
  });
}

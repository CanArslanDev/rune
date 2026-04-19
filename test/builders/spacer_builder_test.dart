import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/spacer_builder.dart';

import '../_helpers/test_context.dart';

Widget _harness(Widget built) => MaterialApp(
      home: Scaffold(
        body: Row(children: [built]),
      ),
    );

void main() {
  group('SpacerBuilder', () {
    const b = SpacerBuilder();

    test('typeName is "Spacer"', () {
      expect(b.typeName, 'Spacer');
    });

    testWidgets('no-args renders a Spacer with flex == 1', (tester) async {
      final built = b.build(ResolvedArguments.empty, testContext());
      await tester.pumpWidget(_harness(built));
      final s = tester.widget<Spacer>(find.byType(Spacer));
      expect(s.flex, 1);
    });

    testWidgets('flex: 3 plumbs through', (tester) async {
      final built = b.build(
        const ResolvedArguments(named: {'flex': 3}),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      final s = tester.widget<Spacer>(find.byType(Spacer));
      expect(s.flex, 3);
    });
  });
}

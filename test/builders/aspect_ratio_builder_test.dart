import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/aspect_ratio_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

Widget _harness(Widget built) => MaterialApp(home: Scaffold(body: built));

void main() {
  group('AspectRatioBuilder', () {
    const b = AspectRatioBuilder();

    test('typeName is "AspectRatio"', () {
      expect(b.typeName, 'AspectRatio');
    });

    testWidgets('aspectRatio plumbs through with a visible child',
        (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {
            'aspectRatio': 16 / 9,
            'child': Text('frame'),
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      final w = tester.widget<AspectRatio>(find.byType(AspectRatio));
      expect(w.aspectRatio, closeTo(16 / 9, 1e-9));
      expect(find.text('frame'), findsOneWidget);
    });

    test('missing aspectRatio throws ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/sliver_list_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('SliverListBuilder', () {
    const b = SliverListBuilder();

    test('typeName is "SliverList"', () {
      expect(b.typeName, 'SliverList');
    });

    testWidgets('renders three children inside a CustomScrollView', (
      tester,
    ) async {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'children': <Object?>[
              Text('one'),
              Text('two'),
              Text('three'),
            ],
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: CustomScrollView(slivers: [w]),
        ),
      );
      expect(find.text('one'), findsOneWidget);
      expect(find.text('two'), findsOneWidget);
      expect(find.text('three'), findsOneWidget);
    });

    test('no args yields an empty SliverList', () {
      final w = b.build(ResolvedArguments.empty, testContext());
      expect(w, isA<SliverList>());
    });
  });
}

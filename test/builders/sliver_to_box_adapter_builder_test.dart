import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/sliver_to_box_adapter_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('SliverToBoxAdapterBuilder', () {
    const b = SliverToBoxAdapterBuilder();

    test('typeName is "SliverToBoxAdapter"', () {
      expect(b.typeName, 'SliverToBoxAdapter');
    });

    testWidgets('child plumbs into a CustomScrollView', (tester) async {
      final w = b.build(
        const ResolvedArguments(named: {'child': Text('header')}),
        testContext(),
      );
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: CustomScrollView(slivers: [w]),
        ),
      );
      expect(find.text('header'), findsOneWidget);
    });

    test('no child is allowed', () {
      final w = b.build(ResolvedArguments.empty, testContext())
          as SliverToBoxAdapter;
      expect(w.child, isNull);
    });
  });
}

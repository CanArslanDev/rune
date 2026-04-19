import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/single_child_scroll_view_builder.dart';

import '../_helpers/test_context.dart';

Widget _harness(Widget built) => MaterialApp(home: Scaffold(body: built));

void main() {
  group('SingleChildScrollViewBuilder', () {
    const b = SingleChildScrollViewBuilder();

    test('typeName is "SingleChildScrollView"', () {
      expect(b.typeName, 'SingleChildScrollView');
    });

    testWidgets('no args renders with default vertical scroll direction',
        (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {
            'child': Column(
              children: [
                SizedBox(height: 2000, child: Text('long')),
              ],
            ),
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      final w = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      expect(w.scrollDirection, Axis.vertical);
      expect(w.reverse, isFalse);
      expect(w.padding, isNull);
      expect(find.text('long'), findsOneWidget);
    });

    testWidgets('scrollDirection horizontal + reverse plumb through',
        (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {
            'scrollDirection': Axis.horizontal,
            'reverse': true,
            'child': SizedBox(width: 2000, child: Text('wide')),
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      final w = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      expect(w.scrollDirection, Axis.horizontal);
      expect(w.reverse, isTrue);
    });

    testWidgets('padding plumbs through', (tester) async {
      final built = b.build(
        const ResolvedArguments(
          named: {
            'padding': EdgeInsets.all(16),
            'child': Text('hi'),
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_harness(built));
      final w = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      expect(w.padding, const EdgeInsets.all(16));
    });
  });
}

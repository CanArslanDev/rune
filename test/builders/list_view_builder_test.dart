import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/list_view_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('ListViewBuilder', () {
    const b = ListViewBuilder();

    test('typeName is "ListView"', () {
      expect(b.typeName, 'ListView');
    });

    test('defaults: vertical, no reverse, no shrink, no padding, empty', () {
      final w = b.build(ResolvedArguments.empty, testContext())
          as ListView;
      expect(w.scrollDirection, Axis.vertical);
      expect(w.reverse, isFalse);
      expect(w.shrinkWrap, isFalse);
      expect(w.padding, isNull);
    });

    test('applies scrollDirection + shrinkWrap + reverse + padding', () {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'scrollDirection': Axis.horizontal,
            'reverse': true,
            'shrinkWrap': true,
            'padding': EdgeInsets.all(4),
          },
        ),
        testContext(),
      ) as ListView;
      expect(w.scrollDirection, Axis.horizontal);
      expect(w.reverse, isTrue);
      expect(w.shrinkWrap, isTrue);
      expect(w.padding, const EdgeInsets.all(4));
    });

    test('children filtered to Widgets', () {
      const a = Text('a');
      const b2 = Text('b');
      final w = b.build(
        const ResolvedArguments(
          named: {'children': <Object?>[a, 'x', b2, null]},
        ),
        testContext(),
      ) as ListView;
      final delegateChildren =
          (w.childrenDelegate as SliverChildListDelegate).children;
      expect(delegateChildren, [a, b2]);
    });
  });
}

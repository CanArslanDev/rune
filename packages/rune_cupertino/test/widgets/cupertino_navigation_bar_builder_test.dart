import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';
import 'package:rune_cupertino/src/widgets/cupertino_navigation_bar_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('CupertinoNavigationBarBuilder', () {
    const b = CupertinoNavigationBarBuilder();

    test('typeName is "CupertinoNavigationBar"', () {
      expect(b.typeName, 'CupertinoNavigationBar');
    });

    test('builds with no args', () {
      final w = b.build(
        ResolvedArguments.empty,
        testContext(),
      ) as CupertinoNavigationBar;
      expect(w.middle, isNull);
      expect(w.leading, isNull);
      expect(w.trailing, isNull);
    });

    test('forwards middle/leading/trailing/backgroundColor', () {
      const middle = Text('Title');
      const leading = Icon(CupertinoIcons.back);
      const trailing = Icon(CupertinoIcons.settings);
      final w = b.build(
        const ResolvedArguments(
          named: {
            'middle': middle,
            'leading': leading,
            'trailing': trailing,
            'backgroundColor': Color(0xFF112233),
          },
        ),
        testContext(),
      ) as CupertinoNavigationBar;
      expect(w.middle, same(middle));
      expect(w.leading, same(leading));
      expect(w.trailing, same(trailing));
      expect(w.backgroundColor, const Color(0xFF112233));
    });

    test('previousPageTitle is forwarded', () {
      final w = b.build(
        const ResolvedArguments(named: {'previousPageTitle': 'Back'}),
        testContext(),
      ) as CupertinoNavigationBar;
      expect(w.previousPageTitle, 'Back');
    });
  });
}

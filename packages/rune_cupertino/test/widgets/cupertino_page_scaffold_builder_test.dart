import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';
import 'package:rune_cupertino/src/widgets/cupertino_page_scaffold_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('CupertinoPageScaffoldBuilder', () {
    const b = CupertinoPageScaffoldBuilder();

    test('typeName is "CupertinoPageScaffold"', () {
      expect(b.typeName, 'CupertinoPageScaffold');
    });

    test('requires child', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('forwards child and background color', () {
      const child = Text('body');
      final w = b.build(
        const ResolvedArguments(
          named: {
            'child': child,
            'backgroundColor': Color(0xFF00FF00),
          },
        ),
        testContext(),
      ) as CupertinoPageScaffold;
      expect(w.child, same(child));
      expect(w.backgroundColor, const Color(0xFF00FF00));
    });

    test('accepts a CupertinoNavigationBar as navigationBar', () {
      const nav = CupertinoNavigationBar(middle: Text('title'));
      final w = b.build(
        const ResolvedArguments(
          named: {
            'child': Text('body'),
            'navigationBar': nav,
          },
        ),
        testContext(),
      ) as CupertinoPageScaffold;
      expect(w.navigationBar, same(nav));
    });

    test('silently drops a non-ObstructingPreferredSizeWidget navigationBar',
        () {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'child': Text('body'),
            'navigationBar': Text('not a nav bar'),
          },
        ),
        testContext(),
      ) as CupertinoPageScaffold;
      expect(w.navigationBar, isNull);
    });
  });
}

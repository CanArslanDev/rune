import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/sliver_app_bar_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('SliverAppBarBuilder', () {
    const b = SliverAppBarBuilder();

    test('typeName is "SliverAppBar"', () {
      expect(b.typeName, 'SliverAppBar');
    });

    test('title + pinned plumb through', () {
      const title = Text('app');
      final w = b.build(
        const ResolvedArguments(
          named: {
            'title': title,
            'pinned': true,
          },
        ),
        testContext(),
      ) as SliverAppBar;
      expect(w.title, same(title));
      expect(w.pinned, isTrue);
      expect(w.floating, isFalse);
      expect(w.snap, isFalse);
    });

    test('floating + snap + expandedHeight plumb through', () {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'floating': true,
            'snap': true,
            'expandedHeight': 200,
          },
        ),
        testContext(),
      ) as SliverAppBar;
      expect(w.floating, isTrue);
      expect(w.snap, isTrue);
      expect(w.expandedHeight, 200.0);
    });

    test('actions filters to Widgets', () {
      const action = Icon(Icons.settings);
      final w = b.build(
        const ResolvedArguments(
          named: {
            'actions': <Object?>[action, null, 'x'],
          },
        ),
        testContext(),
      ) as SliverAppBar;
      expect(w.actions, [action]);
    });

    test('backgroundColor + elevation + centerTitle + flexibleSpace + leading',
        () {
      const leading = Icon(Icons.menu);
      const flex = FlexibleSpaceBar(title: Text('flex'));
      final w = b.build(
        const ResolvedArguments(
          named: {
            'leading': leading,
            'backgroundColor': Color(0xFF112233),
            'elevation': 4,
            'centerTitle': true,
            'flexibleSpace': flex,
          },
        ),
        testContext(),
      ) as SliverAppBar;
      expect(w.leading, same(leading));
      expect(w.backgroundColor, const Color(0xFF112233));
      expect(w.elevation, 4.0);
      expect(w.centerTitle, isTrue);
      expect(w.flexibleSpace, same(flex));
    });
  });
}

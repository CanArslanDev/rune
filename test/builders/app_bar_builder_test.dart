import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/app_bar_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('AppBarBuilder', () {
    const b = AppBarBuilder();

    test('typeName is "AppBar"', () {
      expect(b.typeName, 'AppBar');
    });

    test('bare AppBar with no args', () {
      final w = b.build(ResolvedArguments.empty, testContext());
      expect(w, isA<AppBar>());
    });

    test('applies title + leading + actions + backgroundColor', () {
      const title = Text('Title');
      const leading = Icon(Icons.menu);
      const action1 = Icon(Icons.search);
      final w = b.build(
        const ResolvedArguments(
          named: {
            'title': title,
            'leading': leading,
            'actions': <Object?>[action1],
            'backgroundColor': Color(0xFF2196F3),
            'centerTitle': true,
          },
        ),
        testContext(),
      ) as AppBar;
      expect(w.title, same(title));
      expect(w.leading, same(leading));
      expect(w.actions, [action1]);
      expect(w.backgroundColor, const Color(0xFF2196F3));
      expect(w.centerTitle, isTrue);
    });

    test('empty actions list resolves to null (not [])', () {
      final w = b.build(
        const ResolvedArguments(named: {'actions': <Object?>[]}),
        testContext(),
      ) as AppBar;
      expect(w.actions, isNull);
    });
  });
}

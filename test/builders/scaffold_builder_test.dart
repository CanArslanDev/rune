import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/scaffold_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('ScaffoldBuilder', () {
    const b = ScaffoldBuilder();

    test('typeName is "Scaffold"', () {
      expect(b.typeName, 'Scaffold');
    });

    test('bare Scaffold with no args', () {
      final w = b.build(ResolvedArguments.empty, testContext());
      expect(w, isA<Scaffold>());
    });

    test('applies body + backgroundColor', () {
      const body = Text('body');
      final w = b.build(
        const ResolvedArguments(
          named: {
            'body': body,
            'backgroundColor': Color(0xFFEEEEEE),
          },
        ),
        testContext(),
      ) as Scaffold;
      expect(w.body, same(body));
      expect(w.backgroundColor, const Color(0xFFEEEEEE));
    });

    test('accepts AppBar as appBar slot (PreferredSizeWidget)', () {
      final appBar = AppBar(title: const Text('T'));
      final w = b.build(
        ResolvedArguments(named: {'appBar': appBar}),
        testContext(),
      ) as Scaffold;
      expect(w.appBar, same(appBar));
    });

    test('non-PreferredSizeWidget in appBar slot is dropped', () {
      const notPreferred = Text('not an AppBar');
      final w = b.build(
        const ResolvedArguments(named: {'appBar': notPreferred}),
        testContext(),
      ) as Scaffold;
      expect(w.appBar, isNull);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/tab_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('TabBuilder', () {
    const b = TabBuilder();

    test('typeName is "Tab"', () {
      expect(b.typeName, 'Tab');
    });

    test('text plumbs through', () {
      final built = b.build(
        const ResolvedArguments(named: {'text': 'Home'}),
        testContext(),
      );
      expect(built, isA<Tab>());
      final tab = built as Tab;
      expect(tab.text, 'Home');
      expect(tab.icon, isNull);
    });

    test('icon plumbs through', () {
      const icon = Icon(Icons.home);
      final built = b.build(
        const ResolvedArguments(named: {'icon': icon}),
        testContext(),
      );
      final tab = built as Tab;
      expect(tab.icon, same(icon));
      expect(tab.text, isNull);
    });

    test('text + icon together', () {
      const icon = Icon(Icons.home);
      final built = b.build(
        const ResolvedArguments(named: {'text': 'Home', 'icon': icon}),
        testContext(),
      );
      final tab = built as Tab;
      expect(tab.text, 'Home');
      expect(tab.icon, same(icon));
    });
  });
}

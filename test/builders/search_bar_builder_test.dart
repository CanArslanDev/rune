import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/search_bar_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('SearchBarBuilder', () {
    const b = SearchBarBuilder();

    test('typeName is "SearchBar"', () {
      expect(b.typeName, 'SearchBar');
    });

    test('forwards hintText, leading, and trailing widgets', () {
      const leading = Icon(Icons.search);
      const trailingA = Icon(Icons.clear);
      const trailingB = Icon(Icons.mic);
      final w = b.build(
        const ResolvedArguments(
          named: {
            'hintText': 'Search...',
            'leading': leading,
            'trailing': <Object?>[trailingA, trailingB],
          },
        ),
        testContext(),
      ) as SearchBar;
      expect(w.hintText, 'Search...');
      expect(w.leading, same(leading));
      expect(w.trailing?.length, 2);
    });

    test('non-Widget entries in trailing are filtered out', () {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'trailing': <Object?>[Icon(Icons.clear), 'junk', 7],
          },
        ),
        testContext(),
      ) as SearchBar;
      expect(w.trailing?.length, 1);
    });

    test('onChanged String event dispatches with query value', () {
      final events = RuneEventDispatcher();
      String? received;
      events.register('queryChanged', (String q) => received = q);
      final ctx = testContext(events: events);
      final w = b.build(
        const ResolvedArguments(
          named: {'onChanged': 'queryChanged'},
        ),
        ctx,
      ) as SearchBar;
      w.onChanged!('hello');
      expect(received, 'hello');
    });

    test('onTap String event dispatches on void callback', () {
      final events = RuneEventDispatcher();
      var taps = 0;
      events.register('focused', () => taps++);
      final ctx = testContext(events: events);
      final w = b.build(
        const ResolvedArguments(named: {'onTap': 'focused'}),
        ctx,
      ) as SearchBar;
      w.onTap!();
      expect(taps, 1);
    });

    test('external controller binds through unchanged', () {
      final controller = TextEditingController(text: 'preset');
      final w = b.build(
        ResolvedArguments(named: {'controller': controller}),
        testContext(),
      ) as SearchBar;
      expect(w.controller, same(controller));
      controller.dispose();
    });
  });
}

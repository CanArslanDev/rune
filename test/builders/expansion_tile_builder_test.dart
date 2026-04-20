import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/expansion_tile_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('ExpansionTileBuilder', () {
    const b = ExpansionTileBuilder();

    test('typeName is "ExpansionTile"', () {
      expect(b.typeName, 'ExpansionTile');
    });

    test('builds with required title and default children list', () {
      final w = b.build(
        const ResolvedArguments(named: {'title': Text('Section')}),
        testContext(),
      ) as ExpansionTile;
      expect(w.title, isA<Text>());
      expect(w.children, isEmpty);
      expect(w.initiallyExpanded, isFalse);
    });

    test('missing title raises ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('filters non-Widget children', () {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'title': Text('t'),
            'children': <Object?>[Text('a'), 42, null, Text('b')],
          },
        ),
        testContext(),
      ) as ExpansionTile;
      expect(w.children, hasLength(2));
    });

    test('initiallyExpanded, colors, and padding forwarded', () {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'title': Text('t'),
            'initiallyExpanded': true,
            'backgroundColor': Color(0xFF0000FF),
            'collapsedBackgroundColor': Color(0xFF00FF00),
            'iconColor': Color(0xFFFF0000),
            'textColor': Color(0xFF123456),
            'tilePadding': EdgeInsets.all(4),
            'childrenPadding': EdgeInsets.all(8),
          },
        ),
        testContext(),
      ) as ExpansionTile;
      expect(w.initiallyExpanded, isTrue);
      expect(w.backgroundColor, const Color(0xFF0000FF));
      expect(w.collapsedBackgroundColor, const Color(0xFF00FF00));
      expect(w.iconColor, const Color(0xFFFF0000));
      expect(w.textColor, const Color(0xFF123456));
      expect(w.tilePadding, const EdgeInsets.all(4));
      expect(w.childrenPadding, const EdgeInsets.all(8));
    });

    test('onExpansionChanged event forwards the new bool', () {
      final events = RuneEventDispatcher();
      final captured = <List<Object?>>[];
      events.setCatchAllHandler(
        (n, args) => n == 'expChanged' ? captured.add(args) : null,
      );
      final w = b.build(
        const ResolvedArguments(
          named: {
            'title': Text('t'),
            'onExpansionChanged': 'expChanged',
          },
        ),
        testContext(events: events),
      ) as ExpansionTile;
      expect(w.onExpansionChanged, isNotNull);
      w.onExpansionChanged!.call(true);
      expect(captured, [
        [true],
      ]);
    });
  });
}

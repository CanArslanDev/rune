import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/icon_button_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('IconButtonBuilder', () {
    const b = IconButtonBuilder();

    test('typeName is "IconButton"', () {
      expect(b.typeName, 'IconButton');
    });

    test('dispatches event on onPressed with icon + size + color', () {
      final events = RuneEventDispatcher();
      var count = 0;
      events.register('close', () => count++);
      final ctx = testContext(events: events);
      const iconWidget = Icon(Icons.close);
      final w = b.build(
        const ResolvedArguments(named: {
          'onPressed': 'close',
          'icon': iconWidget,
          'iconSize': 20,
          'color': Color(0xFFFF0000),
        },),
        ctx,
      ) as IconButton;

      expect(w.onPressed, isNotNull);
      w.onPressed!.call();
      expect(count, 1);
      expect(w.icon, same(iconWidget));
      expect(w.iconSize, 20.0);
      expect(w.color, const Color(0xFFFF0000));
    });

    test('missing onPressed leaves button disabled', () {
      final w = b.build(
        const ResolvedArguments(named: {'icon': Icon(Icons.home)}),
        testContext(),
      ) as IconButton;
      expect(w.onPressed, isNull);
    });

    test('missing icon throws ArgumentException', () {
      expect(
        () => b.build(const ResolvedArguments(), testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}

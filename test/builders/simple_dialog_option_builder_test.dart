import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/simple_dialog_option_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('SimpleDialogOptionBuilder', () {
    const b = SimpleDialogOptionBuilder();

    test('typeName is "SimpleDialogOption"', () {
      expect(b.typeName, 'SimpleDialogOption');
    });

    test('child plumbs through', () {
      const child = Text('Option A');
      final w = b.build(
        const ResolvedArguments(named: {'child': child}),
        testContext(),
      ) as SimpleDialogOption;
      expect(w.child, same(child));
    });

    test('onPressed event name fires through the dispatcher', () {
      final events = RuneEventDispatcher();
      final fires = <List<Object?>>[];
      events.setCatchAllHandler((name, args) => fires.add([name, ...args]));
      final w = b.build(
        const ResolvedArguments(named: {'onPressed': 'optionTapped'}),
        testContext(events: events),
      ) as SimpleDialogOption;
      w.onPressed!.call();
      expect(fires.first.first, 'optionTapped');
    });

    test('padding plumbs through', () {
      final w = b.build(
        const ResolvedArguments(
          named: {'padding': EdgeInsets.all(8)},
        ),
        testContext(),
      ) as SimpleDialogOption;
      expect(w.padding, const EdgeInsets.all(8));
    });

    test('no-args renders with null onPressed and null child', () {
      final w = b.build(ResolvedArguments.empty, testContext())
          as SimpleDialogOption;
      expect(w.onPressed, isNull);
      expect(w.child, isNull);
    });
  });
}

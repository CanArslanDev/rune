import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';
import 'package:rune_cupertino/src/widgets/cupertino_dialog_action_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('CupertinoDialogActionBuilder', () {
    const b = CupertinoDialogActionBuilder();

    test('typeName is "CupertinoDialogAction"', () {
      expect(b.typeName, 'CupertinoDialogAction');
    });

    test('requires child', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('wraps onPressed string into a dispatching VoidCallback', () {
      final events = RuneEventDispatcher();
      var count = 0;
      events.register('confirm', () => count++);
      final ctx = testContext(events: events);
      final w = b.build(
        const ResolvedArguments(
          named: {'child': Text('OK'), 'onPressed': 'confirm'},
        ),
        ctx,
      ) as CupertinoDialogAction;
      w.onPressed!.call();
      expect(count, 1);
    });

    test('isDefaultAction and isDestructiveAction default to false', () {
      final w = b.build(
        const ResolvedArguments(named: {'child': Text('x')}),
        testContext(),
      ) as CupertinoDialogAction;
      expect(w.isDefaultAction, isFalse);
      expect(w.isDestructiveAction, isFalse);
    });

    test('destructive flag is forwarded', () {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'child': Text('Delete'),
            'isDestructiveAction': true,
          },
        ),
        testContext(),
      ) as CupertinoDialogAction;
      expect(w.isDestructiveAction, isTrue);
    });

    test('default flag is forwarded', () {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'child': Text('OK'),
            'isDefaultAction': true,
          },
        ),
        testContext(),
      ) as CupertinoDialogAction;
      expect(w.isDefaultAction, isTrue);
    });
  });
}

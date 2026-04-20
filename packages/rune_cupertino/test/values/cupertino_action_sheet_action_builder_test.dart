import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';
import 'package:rune_cupertino/src/values/cupertino_action_sheet_action_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('CupertinoActionSheetActionBuilder', () {
    const b = CupertinoActionSheetActionBuilder();

    test('typeName is "CupertinoActionSheetAction"', () {
      expect(b.typeName, 'CupertinoActionSheetAction');
    });

    test('constructorName is null (default constructor)', () {
      expect(b.constructorName, isNull);
    });

    test('requires child', () {
      expect(
        () => b.build(
          const ResolvedArguments(named: {'onPressed': 'x'}),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('requires onPressed', () {
      expect(
        () => b.build(
          const ResolvedArguments(named: {'child': Text('x')}),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('wraps string onPressed into a dispatching callback', () {
      final events = RuneEventDispatcher();
      var fired = 0;
      events.register('picked', () => fired++);
      final action = b.build(
        const ResolvedArguments(
          named: {'child': Text('Ok'), 'onPressed': 'picked'},
        ),
        testContext(events: events),
      );
      expect(action, isA<CupertinoActionSheetAction>());
      action.onPressed();
      expect(fired, 1);
    });

    test('isDefaultAction and isDestructiveAction forward', () {
      final action = b.build(
        const ResolvedArguments(
          named: {
            'child': Text('Delete'),
            'onPressed': 'del',
            'isDestructiveAction': true,
            'isDefaultAction': true,
          },
        ),
        testContext(),
      );
      expect(action.isDefaultAction, isTrue);
      expect(action.isDestructiveAction, isTrue);
    });

    test('defaults for boolean flags are false', () {
      final action = b.build(
        const ResolvedArguments(
          named: {'child': Text('x'), 'onPressed': 'x'},
        ),
        testContext(),
      );
      expect(action.isDefaultAction, isFalse);
      expect(action.isDestructiveAction, isFalse);
    });
  });
}

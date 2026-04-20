import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/snack_bar_action_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('SnackBarActionBuilder', () {
    const b = SnackBarActionBuilder();

    test('typeName / constructorName', () {
      expect(b.typeName, 'SnackBarAction');
      expect(b.constructorName, isNull);
    });

    test('missing label raises ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(named: {'onPressed': 'tap'}),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('missing onPressed raises ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(named: {'label': 'Undo'}),
          testContext(),
        ),
        throwsA(
          isA<ArgumentException>().having(
            (e) => e.message,
            'message',
            contains('"onPressed"'),
          ),
        ),
      );
    });

    test('label + String-named onPressed dispatches event', () {
      final events = <String>[];
      final ctx = testContext()
        ..events.register('tap', () => events.add('fired'));
      final action = b.build(
        const ResolvedArguments(
          named: {'label': 'Undo', 'onPressed': 'tap'},
        ),
        ctx,
      );
      expect(action.label, 'Undo');
      action.onPressed();
      expect(events, <String>['fired']);
    });

    test('textColor and disabledTextColor plumb through', () {
      final action = b.build(
        const ResolvedArguments(
          named: {
            'label': 'Undo',
            'onPressed': 'tap',
            'textColor': Color(0xFF112233),
            'disabledTextColor': Color(0xFF445566),
          },
        ),
        testContext(),
      );
      expect(action.textColor, const Color(0xFF112233));
      expect(action.disabledTextColor, const Color(0xFF445566));
    });
  });
}

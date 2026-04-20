import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';
import 'package:rune_cupertino/src/widgets/cupertino_action_sheet_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('CupertinoActionSheetBuilder', () {
    const b = CupertinoActionSheetBuilder();

    test('typeName is "CupertinoActionSheet"', () {
      expect(b.typeName, 'CupertinoActionSheet');
    });

    test('builds with title only', () {
      final w = b.build(
        const ResolvedArguments(
          named: {'title': Text('Pick one')},
        ),
        testContext(),
      ) as CupertinoActionSheet;
      expect(w.title, isA<Text>());
      expect(w.actions, isNull);
      expect(w.cancelButton, isNull);
    });

    test('forwards title, message and cancelButton', () {
      const cancel = CupertinoActionSheetAction(
        onPressed: _noop,
        child: Text('Cancel'),
      );
      final w = b.build(
        const ResolvedArguments(
          named: {
            'title': Text('T'),
            'message': Text('M'),
            'cancelButton': cancel,
          },
        ),
        testContext(),
      ) as CupertinoActionSheet;
      expect(w.title, isA<Text>());
      expect(w.message, isA<Text>());
      expect(w.cancelButton, same(cancel));
    });

    test('filters non-Widget entries from actions', () {
      const good = CupertinoActionSheetAction(
        onPressed: _noop,
        child: Text('A'),
      );
      final w = b.build(
        const ResolvedArguments(
          named: {
            'title': Text('T'),
            'actions': <Object?>[good, 42, null],
          },
        ),
        testContext(),
      ) as CupertinoActionSheet;
      expect(w.actions, isNotNull);
      expect(w.actions!.length, 1);
      expect(w.actions!.first, same(good));
    });

    test('accepts an empty actions slot when title is present', () {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'title': Text('T'),
            'actions': <Object?>[],
          },
        ),
        testContext(),
      ) as CupertinoActionSheet;
      expect(w.actions, isNotNull);
      expect(w.actions, isEmpty);
    });
  });
}

void _noop() {}

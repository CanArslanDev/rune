import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';
import 'package:rune_cupertino/src/widgets/cupertino_alert_dialog_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('CupertinoAlertDialogBuilder', () {
    const b = CupertinoAlertDialogBuilder();

    test('typeName is "CupertinoAlertDialog"', () {
      expect(b.typeName, 'CupertinoAlertDialog');
    });

    test('builds with no args', () {
      final w = b.build(
        ResolvedArguments.empty,
        testContext(),
      ) as CupertinoAlertDialog;
      expect(w.title, isNull);
      expect(w.content, isNull);
      expect(w.actions, isEmpty);
    });

    test('forwards title, content, and actions', () {
      const title = Text('Warning');
      const content = Text('Proceed?');
      const buttons = <Widget>[Text('OK'), Text('Cancel')];
      final w = b.build(
        const ResolvedArguments(
          named: {
            'title': title,
            'content': content,
            'actions': <Object?>[...buttons],
          },
        ),
        testContext(),
      ) as CupertinoAlertDialog;
      expect(w.title, same(title));
      expect(w.content, same(content));
      expect(w.actions, buttons);
    });

    test('drops non-Widget entries from actions', () {
      const okBtn = Text('OK');
      final w = b.build(
        const ResolvedArguments(
          named: {
            'actions': <Object?>[okBtn, 42, null, 'string'],
          },
        ),
        testContext(),
      ) as CupertinoAlertDialog;
      expect(w.actions, [okBtn]);
    });
  });
}

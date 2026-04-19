import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/alert_dialog_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('AlertDialogBuilder', () {
    const b = AlertDialogBuilder();

    test('typeName is "AlertDialog"', () {
      expect(b.typeName, 'AlertDialog');
    });

    test('title, content, and actions plumb through', () {
      const title = Text('Confirm');
      const content = Text('Are you sure?');
      const actions = <Widget>[
        Text('Cancel'),
        Text('OK'),
      ];
      final w = b.build(
        const ResolvedArguments(
          named: {
            'title': title,
            'content': content,
            'actions': actions,
          },
        ),
        testContext(),
      ) as AlertDialog;
      expect(w.title, same(title));
      expect(w.content, same(content));
      expect(w.actions, isNotNull);
      expect(w.actions!.length, 2);
    });

    test('backgroundColor, elevation, icon, iconColor plumb through', () {
      const icon = Icon(Icons.info);
      final w = b.build(
        const ResolvedArguments(
          named: {
            'backgroundColor': Color(0xFF112233),
            'elevation': 8,
            'icon': icon,
            'iconColor': Color(0xFF445566),
          },
        ),
        testContext(),
      ) as AlertDialog;
      expect(w.backgroundColor, const Color(0xFF112233));
      expect(w.elevation, 8.0);
      expect(w.icon, same(icon));
      expect(w.iconColor, const Color(0xFF445566));
    });

    test('titleTextStyle and contentTextStyle plumb through', () {
      const titleStyle = TextStyle(fontSize: 20);
      const contentStyle = TextStyle(fontSize: 14);
      final w = b.build(
        const ResolvedArguments(
          named: {
            'titleTextStyle': titleStyle,
            'contentTextStyle': contentStyle,
          },
        ),
        testContext(),
      ) as AlertDialog;
      expect(w.titleTextStyle, same(titleStyle));
      expect(w.contentTextStyle, same(contentStyle));
    });

    test('insetPadding plumbs through', () {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'insetPadding': EdgeInsets.all(24),
          },
        ),
        testContext(),
      ) as AlertDialog;
      expect(w.insetPadding, const EdgeInsets.all(24));
    });

    test('non-Widget entries in actions are filtered out', () {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'actions': <Object?>[Text('OK'), null, 42],
          },
        ),
        testContext(),
      ) as AlertDialog;
      expect(w.actions!.length, 1);
    });

    test('no-args renders without throwing', () {
      final w = b.build(ResolvedArguments.empty, testContext()) as AlertDialog;
      expect(w.title, isNull);
      expect(w.content, isNull);
      expect(w.actions, isNull);
    });
  });
}

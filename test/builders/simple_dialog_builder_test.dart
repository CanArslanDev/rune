import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/simple_dialog_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('SimpleDialogBuilder', () {
    const b = SimpleDialogBuilder();

    test('typeName is "SimpleDialog"', () {
      expect(b.typeName, 'SimpleDialog');
    });

    test('title and children plumb through', () {
      const title = Text('Pick one');
      final w = b.build(
        const ResolvedArguments(
          named: {
            'title': title,
            'children': <Widget>[Text('A'), Text('B')],
          },
        ),
        testContext(),
      ) as SimpleDialog;
      expect(w.title, same(title));
      expect(w.children!.length, 2);
    });

    test('backgroundColor and elevation plumb through', () {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'backgroundColor': Color(0xFF223344),
            'elevation': 6,
          },
        ),
        testContext(),
      ) as SimpleDialog;
      expect(w.backgroundColor, const Color(0xFF223344));
      expect(w.elevation, 6.0);
    });

    test('insetPadding plumbs through', () {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'insetPadding': EdgeInsets.all(16),
          },
        ),
        testContext(),
      ) as SimpleDialog;
      expect(w.insetPadding, const EdgeInsets.all(16));
    });

    test('non-Widget entries in children are filtered out', () {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'children': <Object?>[Text('A'), null, 42],
          },
        ),
        testContext(),
      ) as SimpleDialog;
      expect(w.children!.length, 1);
    });

    test('no-args renders without throwing', () {
      final w = b.build(ResolvedArguments.empty, testContext()) as SimpleDialog;
      expect(w.title, isNull);
      expect(w.children, isNull);
    });
  });
}

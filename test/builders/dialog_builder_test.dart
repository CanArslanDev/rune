import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/dialog_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('DialogBuilder', () {
    const b = DialogBuilder();

    test('typeName is "Dialog"', () {
      expect(b.typeName, 'Dialog');
    });

    test('child, backgroundColor, elevation, insetPadding plumb through', () {
      const child = Text('body');
      final w = b.build(
        const ResolvedArguments(
          named: {
            'child': child,
            'backgroundColor': Color(0xFF001122),
            'elevation': 10,
            'insetPadding': EdgeInsets.all(24),
          },
        ),
        testContext(),
      ) as Dialog;
      expect(w.child, same(child));
      expect(w.backgroundColor, const Color(0xFF001122));
      expect(w.elevation, 10.0);
      expect(w.insetPadding, const EdgeInsets.all(24));
    });

    test('clipBehavior defaults to Clip.none when omitted', () {
      final w = b.build(ResolvedArguments.empty, testContext()) as Dialog;
      expect(w.clipBehavior, Clip.none);
    });

    test('clipBehavior plumbs through when explicit', () {
      final w = b.build(
        const ResolvedArguments(
          named: {'clipBehavior': Clip.antiAlias},
        ),
        testContext(),
      ) as Dialog;
      expect(w.clipBehavior, Clip.antiAlias);
    });

    test('no-args renders without throwing', () {
      final w = b.build(ResolvedArguments.empty, testContext()) as Dialog;
      expect(w.child, isNull);
      expect(w.backgroundColor, isNull);
      expect(w.elevation, isNull);
    });
  });
}

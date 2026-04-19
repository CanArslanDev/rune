import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/offstage_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('OffstageBuilder', () {
    const b = OffstageBuilder();

    test('typeName is "Offstage"', () {
      expect(b.typeName, 'Offstage');
    });

    test('offstage: false renders the child visibly', () {
      const child = Text('x', textDirection: TextDirection.ltr);
      final w = b.build(
        const ResolvedArguments(
          named: {'offstage': false, 'child': child},
        ),
        testContext(),
      ) as Offstage;
      expect(w.offstage, isFalse);
      expect(w.child, same(child));
    });

    test('offstage: true hides the child but keeps it mounted', () {
      const child = Text('x', textDirection: TextDirection.ltr);
      final w = b.build(
        const ResolvedArguments(
          named: {'offstage': true, 'child': child},
        ),
        testContext(),
      ) as Offstage;
      expect(w.offstage, isTrue);
      expect(w.child, same(child));
    });
  });
}

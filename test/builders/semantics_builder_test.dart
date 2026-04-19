import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/semantics_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('SemanticsBuilder', () {
    const b = SemanticsBuilder();

    test('typeName is "Semantics"', () {
      expect(b.typeName, 'Semantics');
    });

    test('label + button + child plumb through', () {
      const child = Text('x');
      final w = b.build(
        const ResolvedArguments(
          named: {
            'label': 'Close button',
            'button': true,
            'child': child,
          },
        ),
        testContext(),
      ) as Semantics;
      expect(w.properties.label, 'Close button');
      expect(w.properties.button, isTrue);
      expect(w.child, same(child));
      expect(w.excludeSemantics, isFalse);
    });

    test('excludeSemantics + container plumb through', () {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'excludeSemantics': true,
            'container': true,
          },
        ),
        testContext(),
      ) as Semantics;
      expect(w.excludeSemantics, isTrue);
      expect(w.container, isTrue);
    });
  });
}

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/stack_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('StackBuilder', () {
    const b = StackBuilder();

    test('typeName is "Stack"', () {
      expect(b.typeName, 'Stack');
    });

    test('builds empty Stack with defaults', () {
      final w = b.build(ResolvedArguments.empty, testContext()) as Stack;
      expect(w.children, isEmpty);
      expect(w.alignment, AlignmentDirectional.topStart);
      expect(w.fit, StackFit.loose);
    });

    test('applies alignment and fit', () {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'alignment': Alignment.center,
            'fit': StackFit.expand,
          },
        ),
        testContext(),
      ) as Stack;
      expect(w.alignment, Alignment.center);
      expect(w.fit, StackFit.expand);
    });

    test('children filtered to Widgets', () {
      const a = Text('a');
      final w = b.build(
        const ResolvedArguments(
          named: {'children': <Object?>[a, 'ignored', 42, null]},
        ),
        testContext(),
      ) as Stack;
      expect(w.children, [a]);
    });
  });
}

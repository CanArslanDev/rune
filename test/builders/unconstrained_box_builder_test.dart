import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/unconstrained_box_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('UnconstrainedBoxBuilder', () {
    const b = UnconstrainedBoxBuilder();

    test('typeName is "UnconstrainedBox"', () {
      expect(b.typeName, 'UnconstrainedBox');
    });

    test('child plumbs through with sensible defaults', () {
      const child = Text('x');
      final w = b.build(
        const ResolvedArguments(named: {'child': child}),
        testContext(),
      ) as UnconstrainedBox;
      expect(w.child, same(child));
      expect(w.alignment, Alignment.center);
      expect(w.constrainedAxis, isNull);
      expect(w.clipBehavior, Clip.none);
    });

    test('constrainedAxis plumbs through', () {
      final w = b.build(
        const ResolvedArguments(
          named: {'constrainedAxis': Axis.horizontal},
        ),
        testContext(),
      ) as UnconstrainedBox;
      expect(w.constrainedAxis, Axis.horizontal);
    });

    test('alignment + clipBehavior plumb through', () {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'alignment': Alignment.topLeft,
            'clipBehavior': Clip.hardEdge,
          },
        ),
        testContext(),
      ) as UnconstrainedBox;
      expect(w.alignment, Alignment.topLeft);
      expect(w.clipBehavior, Clip.hardEdge);
    });
  });
}

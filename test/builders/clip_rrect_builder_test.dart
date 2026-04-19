import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/clip_rrect_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('ClipRRectBuilder', () {
    const b = ClipRRectBuilder();

    test('typeName is "ClipRRect"', () {
      expect(b.typeName, 'ClipRRect');
    });

    test('child plumbs through with defaults', () {
      const child = Text('x');
      final w = b.build(
        const ResolvedArguments(named: {'child': child}),
        testContext(),
      ) as ClipRRect;
      expect(w.child, same(child));
      expect(w.borderRadius, BorderRadius.zero);
      expect(w.clipBehavior, Clip.antiAlias);
    });

    test('borderRadius plumbs through', () {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'borderRadius': BorderRadius.all(Radius.circular(12)),
          },
        ),
        testContext(),
      ) as ClipRRect;
      expect(
        w.borderRadius,
        const BorderRadius.all(Radius.circular(12)),
      );
    });

    test('clipBehavior plumbs through', () {
      final w = b.build(
        const ResolvedArguments(
          named: {'clipBehavior': Clip.hardEdge},
        ),
        testContext(),
      ) as ClipRRect;
      expect(w.clipBehavior, Clip.hardEdge);
    });
  });
}

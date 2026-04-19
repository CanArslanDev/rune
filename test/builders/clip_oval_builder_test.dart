import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/clip_oval_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('ClipOvalBuilder', () {
    const b = ClipOvalBuilder();

    test('typeName is "ClipOval"', () {
      expect(b.typeName, 'ClipOval');
    });

    test('child plumbs through with default clipBehavior', () {
      const child = Text('x');
      final w = b.build(
        const ResolvedArguments(named: {'child': child}),
        testContext(),
      ) as ClipOval;
      expect(w.child, same(child));
      expect(w.clipBehavior, Clip.antiAlias);
    });

    test('clipBehavior plumbs through', () {
      final w = b.build(
        const ResolvedArguments(
          named: {'clipBehavior': Clip.hardEdge},
        ),
        testContext(),
      ) as ClipOval;
      expect(w.clipBehavior, Clip.hardEdge);
    });
  });
}

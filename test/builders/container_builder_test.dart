import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/container_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('ContainerBuilder', () {
    const b = ContainerBuilder();

    test('typeName is "Container"', () {
      expect(b.typeName, 'Container');
    });

    test('builds bare Container with no args', () {
      final w = b.build(ResolvedArguments.empty, testContext());
      expect(w, isA<Container>());
    });

    test('applies padding + size + child', () {
      const child = Text('x');
      final w = b.build(
        const ResolvedArguments(named: {
          'padding': EdgeInsets.all(8),
          'width': 100,
          'height': 50,
          'child': child,
        },),
        testContext(),
      ) as Container;
      expect(w.padding, const EdgeInsets.all(8));
      expect(w.constraints!.minWidth, 100);
      expect(w.constraints!.minHeight, 50);
      expect(w.child, same(child));
    });
  });
}

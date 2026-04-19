import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/hero_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('HeroBuilder', () {
    const b = HeroBuilder();

    test('typeName is "Hero"', () {
      expect(b.typeName, 'Hero');
    });

    test('tag + child plumb through', () {
      const child = Text('hi');
      final w = b.build(
        const ResolvedArguments(
          named: {'tag': 'x', 'child': child},
        ),
        testContext(),
      ) as Hero;
      expect(w.tag, 'x');
      expect(w.child, same(child));
      expect(w.transitionOnUserGestures, isFalse);
    });

    test('missing tag throws ArgumentException mentioning "tag"', () {
      expect(
        () => b.build(
          const ResolvedArguments(
            named: {'child': Text('x')},
          ),
          testContext(),
        ),
        throwsA(
          isA<ArgumentException>().having(
            (e) => e.message,
            'message',
            contains('tag'),
          ),
        ),
      );
    });

    test('explicit tag: null throws ArgumentException mentioning null', () {
      expect(
        () => b.build(
          const ResolvedArguments(
            named: {'tag': null, 'child': Text('x')},
          ),
          testContext(),
        ),
        throwsA(
          isA<ArgumentException>().having(
            (e) => e.message,
            'message',
            contains('null'),
          ),
        ),
      );
    });

    test('transitionOnUserGestures plumbs through', () {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'tag': 42,
            'child': Text('x'),
            'transitionOnUserGestures': true,
          },
        ),
        testContext(),
      ) as Hero;
      expect(w.tag, 42);
      expect(w.transitionOnUserGestures, isTrue);
    });
  });
}

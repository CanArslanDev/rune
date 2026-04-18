import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/icon_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('IconBuilder', () {
    const b = IconBuilder();

    test('typeName is "Icon"', () {
      expect(b.typeName, 'Icon');
    });

    test('builds Icon from positional IconData', () {
      final w = b.build(
        const ResolvedArguments(positional: [Icons.home]),
        testContext(),
      ) as Icon;
      expect(w.icon, Icons.home);
    });

    test('applies size + color', () {
      final w = b.build(
        const ResolvedArguments(
          positional: [Icons.star],
          named: {'size': 32, 'color': Color(0xFFFF0000)},
        ),
        testContext(),
      ) as Icon;
      expect(w.size, 32.0);
      expect(w.color, const Color(0xFFFF0000));
    });

    test('missing IconData throws ArgumentException', () {
      expect(
        () => b.build(const ResolvedArguments(), testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}

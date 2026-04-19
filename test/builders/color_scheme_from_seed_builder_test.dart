import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/color_scheme_from_seed_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('ColorSchemeFromSeedBuilder', () {
    const b = ColorSchemeFromSeedBuilder();

    test('typeName/constructorName identify ColorScheme.fromSeed', () {
      expect(b.typeName, 'ColorScheme');
      expect(b.constructorName, 'fromSeed');
    });

    test('produces a light scheme by default', () {
      final s = b.build(
        const ResolvedArguments(
          named: {'seedColor': Colors.orange},
        ),
        testContext(),
      );
      expect(s.brightness, Brightness.light);
      expect(s, isA<ColorScheme>());
    });

    test('produces a dark scheme when brightness override is given', () {
      final s = b.build(
        const ResolvedArguments(
          named: {
            'seedColor': Colors.green,
            'brightness': Brightness.dark,
          },
        ),
        testContext(),
      );
      expect(s.brightness, Brightness.dark);
    });

    test('matches Flutter ColorScheme.fromSeed primary tone', () {
      final s = b.build(
        const ResolvedArguments(
          named: {'seedColor': Colors.indigo},
        ),
        testContext(),
      );
      final reference = ColorScheme.fromSeed(seedColor: Colors.indigo);
      expect(s.primary, reference.primary);
    });

    test(
      'missing seedColor raises ArgumentException citing the builder',
      () {
        expect(
          () => b.build(ResolvedArguments.empty, testContext()),
          throwsA(
            isA<ArgumentException>().having(
              (e) => e.source,
              'source',
              'ColorScheme.fromSeed',
            ),
          ),
        );
      },
    );
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/step_builder.dart';
import 'package:rune/src/core/exceptions.dart';

import '../_helpers/test_context.dart';

void main() {
  group('StepBuilder', () {
    const b = StepBuilder();

    test('typeName and constructorName', () {
      expect(b.typeName, 'Step');
      expect(b.constructorName, isNull);
    });

    test('builds with required title + content, defaults applied', () {
      final step = b.build(
        const ResolvedArguments(
          named: {'title': Text('Step 1'), 'content': Text('body')},
        ),
        testContext(),
      );
      expect(step, isA<Step>());
      expect(step.subtitle, isNull);
      expect(step.isActive, isFalse);
      expect(step.state, StepState.indexed);
    });

    test('subtitle, isActive, and state honoured', () {
      final step = b.build(
        const ResolvedArguments(
          named: {
            'title': Text('t'),
            'content': Text('c'),
            'subtitle': Text('s'),
            'isActive': true,
            'state': StepState.complete,
          },
        ),
        testContext(),
      );
      expect(step.subtitle, isA<Text>());
      expect(step.isActive, isTrue);
      expect(step.state, StepState.complete);
    });

    test('missing title raises ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(named: {'content': Text('c')}),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('missing content raises ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(named: {'title': Text('t')}),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}

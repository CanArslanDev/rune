import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/stepper_builder.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/parser/dart_parser.dart';
import 'package:rune/src/resolver/expression_resolver.dart';
import 'package:rune/src/resolver/identifier_resolver.dart';
import 'package:rune/src/resolver/invocation_resolver.dart';
import 'package:rune/src/resolver/literal_resolver.dart';
import 'package:rune/src/resolver/property_resolver.dart';
import 'package:rune/src/resolver/rune_closure.dart';

import '../_helpers/test_context.dart';

RuneClosure _closureOf(String source) {
  final parser = DartParser();
  final fn = parser.parse(source) as FunctionExpression;
  final body = (fn.body as ExpressionFunctionBody).expression;
  final paramNames = <String>[];
  final parameterList = fn.parameters;
  if (parameterList != null) {
    for (final param in parameterList.parameters) {
      final nameToken = param.name;
      if (nameToken != null) paramNames.add(nameToken.lexeme);
    }
  }
  final expr = ExpressionResolver(LiteralResolver(), IdentifierResolver());
  expr
    ..bindProperty(PropertyResolver(expr))
    ..bind(InvocationResolver(expr));
  return RuneClosure.expression(
    parameterNames: paramNames,
    body: body,
    capturedContext: testContext(),
    resolver: expr,
  );
}

Step _step(String t) => Step(title: Text(t), content: Text('c-$t'));

void main() {
  group('StepperBuilder', () {
    const b = StepperBuilder();

    test('typeName is "Stepper"', () {
      expect(b.typeName, 'Stepper');
    });

    test('builds with required steps list', () {
      final w = b.build(
        ResolvedArguments(
          named: {
            'steps': <Object?>[_step('a'), _step('b')],
          },
        ),
        testContext(),
      ) as Stepper;
      expect(w.steps, hasLength(2));
      expect(w.currentStep, 0);
      expect(w.type, StepperType.vertical);
      expect(w.onStepTapped, isNull);
      expect(w.onStepContinue, isNull);
      expect(w.onStepCancel, isNull);
    });

    test('non-Step entries are filtered', () {
      final w = b.build(
        ResolvedArguments(
          named: {
            'steps': <Object?>[_step('a'), 'bogus', 7],
          },
        ),
        testContext(),
      ) as Stepper;
      expect(w.steps, hasLength(1));
    });

    test('missing steps raises ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('currentStep and type forwarded', () {
      final w = b.build(
        ResolvedArguments(
          named: {
            'steps': <Object?>[_step('a'), _step('b')],
            'currentStep': 1,
            'type': StepperType.horizontal,
          },
        ),
        testContext(),
      ) as Stepper;
      expect(w.currentStep, 1);
      expect(w.type, StepperType.horizontal);
    });

    test('onStepContinue and onStepCancel event names dispatch', () {
      final events = RuneEventDispatcher();
      final fired = <String>[];
      events.setCatchAllHandler((n, _) => fired.add(n));
      final w = b.build(
        ResolvedArguments(
          named: {
            'steps': <Object?>[_step('a')],
            'onStepContinue': 'continueEvt',
            'onStepCancel': 'cancelEvt',
          },
        ),
        testContext(events: events),
      ) as Stepper;
      expect(w.onStepContinue, isNotNull);
      expect(w.onStepCancel, isNotNull);
      w.onStepContinue!.call();
      w.onStepCancel!.call();
      expect(fired, ['continueEvt', 'cancelEvt']);
    });

    test('onStepTapped closure is installed', () {
      final w = b.build(
        ResolvedArguments(
          named: {
            'steps': <Object?>[_step('a')],
            'onStepTapped': _closureOf('(i) => 0'),
          },
        ),
        testContext(),
      ) as Stepper;
      expect(w.onStepTapped, isNotNull);
      w.onStepTapped!.call(0);
    });

    test('onStepTapped with wrong arity raises ArgumentException', () {
      expect(
        () => b.build(
          ResolvedArguments(
            named: {
              'steps': <Object?>[_step('a')],
              'onStepTapped': _closureOf('(i, j) => 0'),
            },
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}

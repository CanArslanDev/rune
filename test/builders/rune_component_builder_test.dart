import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/rune_component_builder.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_component.dart';
import 'package:rune/src/parser/dart_parser.dart';
import 'package:rune/src/registry/component_registry.dart';
import 'package:rune/src/resolver/expression_resolver.dart';
import 'package:rune/src/resolver/identifier_resolver.dart';
import 'package:rune/src/resolver/literal_resolver.dart';
import 'package:rune/src/resolver/rune_closure.dart';

import '../_helpers/test_context.dart';

RuneClosure _arrowClosure(
  DartParser parser,
  String source, {
  required ExpressionResolver resolver,
}) {
  final expr = parser.parse(source);
  final fn = expr as FunctionExpression;
  final params = fn.parameters!.parameters
      .whereType<NormalFormalParameter>()
      .map((p) => p.name!.lexeme)
      .toList();
  final body = (fn.body as ExpressionFunctionBody).expression;
  return RuneClosure.expression(
    parameterNames: params,
    body: body,
    capturedContext: testContext(),
    resolver: resolver,
  );
}

void main() {
  final parser = DartParser();
  final resolver = ExpressionResolver(LiteralResolver(), IdentifierResolver());

  group('RuneComponentBuilder', () {
    test('typeName == "RuneComponent" and default constructor', () {
      const b = RuneComponentBuilder();
      expect(b.typeName, 'RuneComponent');
      expect(b.constructorName, isNull);
    });

    test(
      'registers a RuneComponent in ctx.components and returns the component',
      () {
        const b = RuneComponentBuilder();
        final closure = _arrowClosure(
          parser,
          '(who) => who',
          resolver: resolver,
        );
        final components = ComponentRegistry();
        final ctx = testContext(components: components);
        final args = ResolvedArguments(
          named: <String, Object?>{
            'name': 'Greeting',
            'params': const <Object?>['who'],
            'body': closure,
          },
        );
        final built = b.build(args, ctx);
        expect(built, isA<RuneComponent>());
        expect(built.name, 'Greeting');
        expect(components.find('Greeting'), same(built));
      },
    );

    test('missing `name` raises ArgumentException', () {
      const b = RuneComponentBuilder();
      final closure = _arrowClosure(parser, '() => 1', resolver: resolver);
      expect(
        () => b.build(
          ResolvedArguments(
            named: <String, Object?>{
              'params': const <Object?>[],
              'body': closure,
            },
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('missing `params` raises ArgumentException', () {
      const b = RuneComponentBuilder();
      final closure = _arrowClosure(parser, '() => 1', resolver: resolver);
      expect(
        () => b.build(
          ResolvedArguments(
            named: <String, Object?>{
              'name': 'Foo',
              'body': closure,
            },
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('missing `body` raises ArgumentException', () {
      const b = RuneComponentBuilder();
      expect(
        () => b.build(
          const ResolvedArguments(
            named: <String, Object?>{
              'name': 'Foo',
              'params': <Object?>[],
            },
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('body arity mismatching params length raises ArgumentException', () {
      const b = RuneComponentBuilder();
      final closure = _arrowClosure(parser, '(a, b) => a', resolver: resolver);
      expect(
        () => b.build(
          ResolvedArguments(
            named: <String, Object?>{
              'name': 'Foo',
              'params': const <Object?>['only'],
              'body': closure,
            },
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}

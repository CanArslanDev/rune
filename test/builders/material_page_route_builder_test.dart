import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/material_page_route_builder.dart';
import 'package:rune/src/builders/widgets/text_builder.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/parser/dart_parser.dart';
import 'package:rune/src/registry/widget_registry.dart';
import 'package:rune/src/resolver/expression_resolver.dart';
import 'package:rune/src/resolver/identifier_resolver.dart';
import 'package:rune/src/resolver/invocation_resolver.dart';
import 'package:rune/src/resolver/literal_resolver.dart';
import 'package:rune/src/resolver/property_resolver.dart';
import 'package:rune/src/resolver/rune_closure.dart';

import '../_helpers/test_context.dart';

/// Parses [source] (e.g. `"(ctx) => Text('hi')"`) as a [RuneClosure] with
/// a live resolver pipeline so it can be fed into value-builder tests.
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
  final widgets = WidgetRegistry()..registerBuilder(const TextBuilder());
  return RuneClosure.expression(
    parameterNames: paramNames,
    body: body,
    capturedContext: testContext(widgets: widgets),
    resolver: expr,
  );
}

void main() {
  group('MaterialPageRouteBuilder', () {
    const b = MaterialPageRouteBuilder();

    test('typeName is "MaterialPageRoute" and constructorName is null', () {
      expect(b.typeName, 'MaterialPageRoute');
      expect(b.constructorName, isNull);
    });

    test('missing builder raises ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('builder of wrong arity raises ArgumentException', () {
      final closure = _closureOf("() => Text('bad')");
      expect(
        () => b.build(
          ResolvedArguments(named: {'builder': closure}),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('valid builder produces a MaterialPageRoute with defaults', () {
      final closure = _closureOf("(ctx) => Text('Detail')");
      final route = b.build(
        ResolvedArguments(named: {'builder': closure}),
        testContext(),
      );
      expect(route, isA<MaterialPageRoute<Object?>>());
      expect(route.fullscreenDialog, isFalse);
      expect(route.maintainState, isTrue);
      expect(route.settings.name, isNull);
    });

    test('fullscreenDialog, maintainState, settings plumb through', () {
      final closure = _closureOf("(ctx) => Text('Detail')");
      const settings = RouteSettings(name: '/detail');
      final route = b.build(
        ResolvedArguments(
          named: {
            'builder': closure,
            'fullscreenDialog': true,
            'maintainState': false,
            'settings': settings,
          },
        ),
        testContext(),
      );
      expect(route.fullscreenDialog, isTrue);
      expect(route.maintainState, isFalse);
      expect(route.settings.name, '/detail');
    });
  });
}

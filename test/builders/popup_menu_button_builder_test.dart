import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter/material.dart' hide PopupMenuItemBuilder;
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/popup_menu_button_builder.dart';
import 'package:rune/src/builders/widgets/popup_menu_divider_builder.dart';
import 'package:rune/src/builders/widgets/popup_menu_item_builder.dart';
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
  final widgets = WidgetRegistry()
    ..registerBuilder(const TextBuilder())
    ..registerBuilder(const PopupMenuItemBuilder())
    ..registerBuilder(const PopupMenuDividerBuilder());
  return RuneClosure.expression(
    parameterNames: paramNames,
    body: body,
    capturedContext: testContext(widgets: widgets),
    resolver: expr,
  );
}

void main() {
  group('PopupMenuButtonBuilder', () {
    const b = PopupMenuButtonBuilder();

    test('typeName is "PopupMenuButton"', () {
      expect(b.typeName, 'PopupMenuButton');
    });

    test('missing itemBuilder throws ArgumentException', () {
      expect(
        () => b.build(ResolvedArguments.empty, testContext()),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('non-closure itemBuilder throws ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(named: {'itemBuilder': 'nope'}),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('wrong-arity itemBuilder throws ArgumentException', () {
      expect(
        () => b.build(
          ResolvedArguments(
            named: {
              'itemBuilder': _closureOf('() => []'),
            },
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('tooltip, elevation, enabled, icon plumb through', () {
      const icon = Icon(Icons.more_vert);
      final w = b.build(
        ResolvedArguments(
          named: {
            'itemBuilder': _closureOf('(c) => []'),
            'tooltip': 'More',
            'elevation': 4,
            'enabled': false,
            'icon': icon,
          },
        ),
        testContext(),
      ) as PopupMenuButton<Object?>;
      expect(w.tooltip, 'More');
      expect(w.elevation, 4.0);
      expect(w.enabled, isFalse);
      expect(w.icon, same(icon));
    });
  });
}

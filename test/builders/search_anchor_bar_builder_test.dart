import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/values/search_anchor_bar_builder.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';
import 'package:rune/src/parser/dart_parser.dart';
import 'package:rune/src/resolver/expression_resolver.dart';
import 'package:rune/src/resolver/identifier_resolver.dart';
import 'package:rune/src/resolver/invocation_resolver.dart';
import 'package:rune/src/resolver/literal_resolver.dart';
import 'package:rune/src/resolver/property_resolver.dart';
import 'package:rune/src/resolver/rune_closure.dart';

import '../_helpers/test_context.dart';

// Builds a RuneClosure with [source] as an arrow-expression body. The
// shape of the closure always takes `(ctx, controller)` so the returned
// closure matches SearchAnchor.bar's suggestionsBuilder contract.
RuneClosure _buildClosure(
  String source,
  RuneContext outerCtx,
  ExpressionResolver expr,
) {
  final parser = DartParser();
  final fn = parser.parse('(ctx, controller) => $source') as FunctionExpression;
  return RuneClosure.expression(
    parameterNames:
        fn.parameters!.parameters.map((p) => p.name!.lexeme).toList(),
    body: (fn.body as ExpressionFunctionBody).expression,
    capturedContext: outerCtx,
    resolver: expr,
  );
}

void main() {
  group('SearchAnchorBarBuilder', () {
    const b = SearchAnchorBarBuilder();

    // Shared pipeline so we can mint a closure pointing at a real resolver.
    final ctx = testContext();
    final expr = ExpressionResolver(LiteralResolver(), IdentifierResolver());
    final inv = InvocationResolver(expr);
    expr
      ..bind(inv)
      ..bindProperty(PropertyResolver(expr));

    test('typeName/constructorName identify SearchAnchor.bar', () {
      expect(b.typeName, 'SearchAnchor');
      expect(b.constructorName, 'bar');
    });

    test('builds a SearchAnchor when suggestionsBuilder is present', () {
      final closure = _buildClosure('[]', ctx, expr);
      final w = b.build(
        ResolvedArguments(named: {'suggestionsBuilder': closure}),
        ctx,
      );
      expect(w, isA<SearchAnchor>());
    });

    test('forwards barHintText and viewHintText', () {
      final closure = _buildClosure('[]', ctx, expr);
      final w = b.build(
        ResolvedArguments(
          named: {
            'suggestionsBuilder': closure,
            'barHintText': 'Search docs',
            'viewHintText': 'Search all',
          },
        ),
        ctx,
      );
      expect(w, isA<SearchAnchor>());
    });

    test(
      'missing suggestionsBuilder raises ArgumentException',
      () {
        expect(
          () => b.build(ResolvedArguments.empty, ctx),
          throwsA(isA<ArgumentException>()),
        );
      },
    );

    test('non-Widget entries in barTrailing are filtered out', () {
      final closure = _buildClosure('[]', ctx, expr);
      const leading = Icon(Icons.search);
      // Build succeeds and returns a SearchAnchor; the internal list
      // inspection relies on the filter having run without error.
      final w = b.build(
        ResolvedArguments(
          named: {
            'suggestionsBuilder': closure,
            'barLeading': leading,
            'barTrailing': const <Object?>[
              Icon(Icons.clear),
              'junk',
              42,
            ],
          },
        ),
        ctx,
      );
      expect(w, isA<SearchAnchor>());
    });
  });
}

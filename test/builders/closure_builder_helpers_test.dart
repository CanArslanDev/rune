import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/closure_builder_helpers.dart';
import 'package:rune/src/builders/widgets/text_builder.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';
import 'package:rune/src/parser/dart_parser.dart';
import 'package:rune/src/registry/widget_registry.dart';
import 'package:rune/src/resolver/expression_resolver.dart';
import 'package:rune/src/resolver/identifier_resolver.dart';
import 'package:rune/src/resolver/invocation_resolver.dart';
import 'package:rune/src/resolver/literal_resolver.dart';
import 'package:rune/src/resolver/property_resolver.dart';
import 'package:rune/src/resolver/rune_closure.dart';

import '../_helpers/test_context.dart';

/// Wraps [source] (e.g. `"(ctx, i) => Text('\${i}')"`) as a [RuneClosure]
/// with a fully wired resolver pipeline including the Text builder.
RuneClosure _closureOf(String source, {RuneContext? ctx}) {
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
  final capturedCtx = ctx ?? testContext(widgets: widgets);
  return RuneClosure.expression(
    parameterNames: paramNames,
    body: body,
    capturedContext: capturedCtx,
    resolver: expr,
  );
}

void main() {
  group('toIndexedBuilder', () {
    test('null source throws ArgumentException', () {
      expect(
        () => toIndexedBuilder(null, 'ListView.builder'),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('non-closure source throws ArgumentException', () {
      expect(
        () => toIndexedBuilder('not-a-closure', 'ListView.builder'),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('closure with wrong arity throws ArgumentException', () {
      final closure = _closureOf("(i) => Text('bad')");
      expect(
        () => toIndexedBuilder(closure, 'ListView.builder'),
        throwsA(isA<ArgumentException>()),
      );
    });

    testWidgets('valid closure yields IndexedWidgetBuilder', (tester) async {
      final closure = _closureOf("(ctx, i) => Text('item')");
      final fn = toIndexedBuilder(closure, 'ListView.builder');
      Widget? built;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) => built = fn(ctx, 0),
          ),
        ),
      );
      expect(built, isA<Text>());
      expect((built! as Text).data, 'item');
    });

    testWidgets('closure returning non-Widget raises ResolveException',
        (tester) async {
      final closure = _closureOf('(ctx, i) => 42');
      final fn = toIndexedBuilder(closure, 'ListView.builder');
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) {
              expect(
                () => fn(ctx, 0),
                throwsA(isA<ResolveException>()),
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });
  });

  group('toFutureSnapshotBuilder', () {
    test('null source throws ArgumentException', () {
      expect(
        () => toFutureSnapshotBuilder(null, 'FutureBuilder'),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('non-closure source throws ArgumentException', () {
      expect(
        () => toFutureSnapshotBuilder(5, 'FutureBuilder'),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('wrong-arity closure throws ArgumentException', () {
      final closure = _closureOf("(snapshot) => Text('hi')");
      expect(
        () => toFutureSnapshotBuilder(closure, 'FutureBuilder'),
        throwsA(isA<ArgumentException>()),
      );
    });

    testWidgets('valid closure yields AsyncWidgetBuilder<Object?>',
        (tester) async {
      final closure = _closureOf("(ctx, snapshot) => Text('ok')");
      final fn = toFutureSnapshotBuilder(closure, 'FutureBuilder');
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) {
              final w = fn(
                ctx,
                const AsyncSnapshot<Object?>.withData(
                  ConnectionState.done,
                  'hi',
                ),
              );
              expect(w, isA<Text>());
              return w;
            },
          ),
        ),
      );
    });
  });

  group('toStreamSnapshotBuilder', () {
    test('null source throws ArgumentException', () {
      expect(
        () => toStreamSnapshotBuilder(null, 'StreamBuilder'),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('wrong-arity closure throws ArgumentException', () {
      final closure = _closureOf('(snapshot) => snapshot');
      expect(
        () => toStreamSnapshotBuilder(closure, 'StreamBuilder'),
        throwsA(isA<ArgumentException>()),
      );
    });
  });

  group('toLayoutBuilder', () {
    test('null source throws ArgumentException', () {
      expect(
        () => toLayoutBuilder(null, 'LayoutBuilder'),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('wrong-arity closure throws ArgumentException', () {
      final closure = _closureOf("(c) => Text('x')");
      expect(
        () => toLayoutBuilder(closure, 'LayoutBuilder'),
        throwsA(isA<ArgumentException>()),
      );
    });
  });

  group('toOrientationBuilder', () {
    test('null source throws ArgumentException', () {
      expect(
        () => toOrientationBuilder(null, 'OrientationBuilder'),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('wrong-arity closure throws ArgumentException', () {
      final closure = _closureOf("(o) => Text('x')");
      expect(
        () => toOrientationBuilder(closure, 'OrientationBuilder'),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}

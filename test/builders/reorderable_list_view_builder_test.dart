import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/reorderable_list_view_builder.dart';
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

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('ReorderableListViewBuilder', () {
    const b = ReorderableListViewBuilder();

    test('typeName is "ReorderableListView"', () {
      expect(b.typeName, 'ReorderableListView');
    });

    test('missing onReorder raises ArgumentException', () {
      expect(
        () => b.build(
          const ResolvedArguments(
            named: {
              'children': <Object?>[
                Text('a', key: ValueKey<Object>('a')),
              ],
            },
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('wrong-arity onReorder raises ArgumentException', () {
      expect(
        () => b.build(
          ResolvedArguments(
            named: {
              'children': const <Object?>[
                Text('a', key: ValueKey<Object>('a')),
              ],
              'onReorder': _closureOf('(x) => 1'),
            },
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    testWidgets('renders keyed children', (tester) async {
      final built = b.build(
        ResolvedArguments(
          named: {
            'children': const <Object?>[
              ListTile(
                key: ValueKey<Object>('a'),
                title: Text('Alpha'),
              ),
              ListTile(
                key: ValueKey<Object>('b'),
                title: Text('Beta'),
              ),
            ],
            'onReorder': _closureOf('(o, n) => 1'),
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_wrap(built));
      expect(find.byType(ReorderableListView), findsOneWidget);
      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);
    });

    testWidgets('children filter drops non-Widget entries', (tester) async {
      final built = b.build(
        ResolvedArguments(
          named: {
            'children': const <Object?>[
              ListTile(
                key: ValueKey<Object>('a'),
                title: Text('Alpha'),
              ),
              'not a widget',
            ],
            'onReorder': _closureOf('(o, n) => 1'),
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_wrap(built));
      expect(find.text('Alpha'), findsOneWidget);
    });

    testWidgets('scrollDirection override routes through', (tester) async {
      final built = b.build(
        ResolvedArguments(
          named: {
            'children': const <Object?>[
              SizedBox(key: ValueKey<Object>('a'), width: 50, height: 50),
            ],
            'onReorder': _closureOf('(o, n) => 1'),
            'scrollDirection': Axis.horizontal,
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_wrap(built));
      final w = tester.widget<ReorderableListView>(
        find.byType(ReorderableListView),
      );
      expect(w.scrollDirection, Axis.horizontal);
    });
  });
}

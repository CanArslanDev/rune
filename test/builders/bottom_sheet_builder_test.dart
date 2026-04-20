import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/builders/widgets/bottom_sheet_builder.dart';
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
  final widgets = WidgetRegistry()..registerBuilder(const TextBuilder());
  return RuneClosure.expression(
    parameterNames: paramNames,
    body: body,
    capturedContext: testContext(widgets: widgets),
    resolver: expr,
  );
}

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('BottomSheetBuilder', () {
    const b = BottomSheetBuilder();

    test('typeName is "BottomSheet"', () {
      expect(b.typeName, 'BottomSheet');
    });

    test('missing onClosing raises ArgumentException', () {
      expect(
        () => b.build(
          ResolvedArguments(
            named: {'builder': _closureOf("(c) => Text('x')")},
          ),
          testContext(),
        ),
        throwsA(
          isA<ArgumentException>().having(
            (e) => e.message,
            'message',
            contains('"onClosing"'),
          ),
        ),
      );
    });

    test('missing builder raises ArgumentException', () {
      expect(
        () => b.build(
          ResolvedArguments(
            named: {'onClosing': _closureOf('() => null')},
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    testWidgets('mounts a sheet and renders the builder result',
        (tester) async {
      final w = b.build(
        ResolvedArguments(
          named: <String, Object?>{
            'onClosing': _closureOf('() => null'),
            'builder': _closureOf("(c) => Text('SheetBody')"),
          },
        ),
        testContext(),
      );
      await tester.pumpWidget(_wrap(w));
      expect(find.text('SheetBody'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    test('backgroundColor, elevation, enableDrag plumb through', () {
      final w = b.build(
        ResolvedArguments(
          named: <String, Object?>{
            'onClosing': _closureOf('() => null'),
            'builder': _closureOf("(c) => Text('x')"),
            'backgroundColor': const Color(0xFF112233),
            'elevation': 8,
            'enableDrag': false,
          },
        ),
        testContext(),
      ) as BottomSheet;
      expect(w.backgroundColor, const Color(0xFF112233));
      expect(w.elevation, 8.0);
      expect(w.enableDrag, isFalse);
    });

    test('String onClosing dispatches as a named event', () {
      final events = <String>[];
      final ctx = testContext()
        ..events.register('close', () => events.add('fired'));
      final w = b.build(
        ResolvedArguments(
          named: <String, Object?>{
            'onClosing': 'close',
            'builder': _closureOf("(c) => Text('x')"),
          },
        ),
        ctx,
      ) as BottomSheet;
      w.onClosing();
      expect(events, <String>['fired']);
    });
  });
}

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_data_context.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';
import 'package:rune/src/parser/dart_parser.dart';
import 'package:rune/src/registry/constant_registry.dart';
import 'package:rune/src/registry/extension_registry.dart';
import 'package:rune/src/registry/value_registry.dart';
import 'package:rune/src/registry/widget_registry.dart';
import 'package:rune/src/resolver/expression_resolver.dart';
import 'package:rune/src/resolver/identifier_resolver.dart';
import 'package:rune/src/resolver/invocation_resolver.dart';
import 'package:rune/src/resolver/literal_resolver.dart';
import 'package:rune/src/resolver/property_resolver.dart';

import '../_helpers/test_context.dart';

final class _NoopWidget implements RuneWidgetBuilder {
  const _NoopWidget(this.typeName);
  @override
  final String typeName;
  @override
  Widget build(ResolvedArguments args, RuneContext ctx) =>
      const SizedBox.shrink();
}

final class _NoopValue implements RuneValueBuilder {
  const _NoopValue(this.typeName, [this.constructorName]);
  @override
  final String typeName;
  @override
  final String? constructorName;
  @override
  Object build(ResolvedArguments args, RuneContext ctx) => Object();
}

typedef _Pipeline = ({
  ExpressionResolver expr,
  RuneContext ctx,
});

_Pipeline _buildPipeline({
  List<RuneWidgetBuilder> widgets = const [],
  List<RuneValueBuilder> values = const [],
  Map<String, Object?> data = const {},
  ConstantRegistry? constants,
  ExtensionRegistry? extensions,
  String source = '',
}) {
  final wr = WidgetRegistry();
  for (final w in widgets) {
    wr.registerBuilder(w);
  }
  final vr = ValueRegistry();
  for (final v in values) {
    vr.registerBuilder(v);
  }
  final ctx = testContext(
    widgets: wr,
    values: vr,
    constants: constants,
    extensions: extensions,
    data: RuneDataContext(data),
    source: source,
  );
  final expr = ExpressionResolver(LiteralResolver(), IdentifierResolver());
  final inv = InvocationResolver(expr);
  expr
    ..bind(inv)
    ..bindProperty(PropertyResolver(expr));
  return (expr: expr, ctx: ctx);
}

void main() {
  final parser = DartParser();

  group('UnregisteredBuilderException: did-you-mean suggestions', () {
    test('suggests a widget builder on typo (Colums → Column)', () {
      final p = _buildPipeline(widgets: [const _NoopWidget('Column')]);
      expect(
        () => p.expr.resolve(parser.parse('Colums()'), p.ctx),
        throwsA(
          isA<UnregisteredBuilderException>().having(
            (e) => e.message,
            'message',
            contains('did you mean "Column"?'),
          ),
        ),
      );
    });

    test('suggests a value builder by type name (new-keyword form)', () {
      final p = _buildPipeline(values: [const _NoopValue('EdgeInsets', 'all')]);
      expect(
        () => p.expr.resolve(parser.parse('new EdgInsets.all(1)'), p.ctx),
        throwsA(
          isA<UnregisteredBuilderException>().having(
            (e) => e.message,
            'message',
            contains('did you mean "EdgeInsets"?'),
          ),
        ),
      );
    });

    test('omits suggestion when no candidate is within threshold', () {
      final p = _buildPipeline(widgets: [const _NoopWidget('Column')]);
      expect(
        () => p.expr.resolve(parser.parse('XyzzyQuux()'), p.ctx),
        throwsA(
          isA<UnregisteredBuilderException>().having(
            (e) => e.message,
            'message',
            isNot(contains('did you mean')),
          ),
        ),
      );
    });
  });

  group('BindingException: did-you-mean suggestions', () {
    test('suggests a close data key', () {
      final p = _buildPipeline(
        widgets: [const _NoopWidget('Text')],
        data: {'userName': 'Ada', 'userAge': 30},
      );
      expect(
        () => p.expr.resolve(parser.parse('Text(userNam)'), p.ctx),
        throwsA(
          isA<BindingException>().having(
            (e) => e.message,
            'message',
            contains('did you mean "userName"?'),
          ),
        ),
      );
    });

    test('omits suggestion when data is empty', () {
      final p = _buildPipeline(widgets: [const _NoopWidget('Text')]);
      expect(
        () => p.expr.resolve(parser.parse('Text(foo)'), p.ctx),
        throwsA(
          isA<BindingException>().having(
            (e) => e.message,
            'message',
            isNot(contains('did you mean')),
          ),
        ),
      );
    });
  });

  group('ResolveException on constants: did-you-mean suggestions', () {
    test('suggests a sibling member when the type is known', () {
      final constants = ConstantRegistry()
        ..register('Colors', 'red', const Color(0xFFFF0000))
        ..register('Colors', 'blue', const Color(0xFF0000FF));
      final p = _buildPipeline(
        widgets: [const _NoopWidget('Text')],
        constants: constants,
      );
      expect(
        () => p.expr.resolve(parser.parse('Text(Colors.redd)'), p.ctx),
        throwsA(
          isA<ResolveException>().having(
            (e) => e.message,
            'message',
            contains('did you mean "red"?'),
          ),
        ),
      );
    });

    test('suggests a sibling type when the type itself is misspelled', () {
      final constants = ConstantRegistry()
        ..register('Colors', 'red', const Color(0xFFFF0000))
        ..register('Colors', 'blue', const Color(0xFF0000FF));
      final p = _buildPipeline(
        widgets: [const _NoopWidget('Text')],
        constants: constants,
      );
      expect(
        () => p.expr.resolve(parser.parse('Text(Colros.red)'), p.ctx),
        throwsA(
          isA<ResolveException>().having(
            (e) => e.message,
            'message',
            contains('did you mean "Colors"?'),
          ),
        ),
      );
    });
  });

  group('ResolveException on built-in methods: did-you-mean suggestions', () {
    test('suggests close String method (toUppercase → toUpperCase)', () {
      final p = _buildPipeline(
        widgets: [const _NoopWidget('Text')],
        data: {'name': 'ada'},
      );
      expect(
        () => p.expr.resolve(parser.parse('Text(name.toUppercase())'), p.ctx),
        throwsA(
          isA<ResolveException>().having(
            (e) => e.message,
            'message',
            contains('did you mean "toUpperCase"?'),
          ),
        ),
      );
    });

    test('suggests close List method (fristWhere → firstWhere)', () {
      final p = _buildPipeline(
        widgets: [const _NoopWidget('Text')],
        data: {'items': <Object?>[1, 2, 3]},
      );
      expect(
        () => p.expr.resolve(
          parser.parse('Text(items.fristWhere((x) => x == 2))'),
          p.ctx,
        ),
        throwsA(
          isA<ResolveException>().having(
            (e) => e.message,
            'message',
            contains('did you mean "firstWhere"?'),
          ),
        ),
      );
    });
  });

  group(
    'ResolveException on built-in properties: did-you-mean suggestions',
    () {
      test('suggests close String property (lenght → length)', () {
        final p = _buildPipeline(
          widgets: [const _NoopWidget('Text')],
          data: {'name': 'ada'},
        );
        expect(
          () => p.expr.resolve(parser.parse('Text(name.lenght)'), p.ctx),
          throwsA(
            isA<ResolveException>().having(
              (e) => e.message,
              'message',
              contains('did you mean "length"?'),
            ),
          ),
        );
      });
    },
  );
}

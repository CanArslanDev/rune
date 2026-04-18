import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';
import 'package:rune/src/parser/dart_parser.dart';
import 'package:rune/src/registry/value_registry.dart';
import 'package:rune/src/registry/widget_registry.dart';
import 'package:rune/src/resolver/expression_resolver.dart';
import 'package:rune/src/resolver/identifier_resolver.dart';
import 'package:rune/src/resolver/invocation_resolver.dart';
import 'package:rune/src/resolver/literal_resolver.dart';

import '../_helpers/test_context.dart';

final class _RecordingWidget implements RuneWidgetBuilder {
  _RecordingWidget(this.typeName);
  @override
  final String typeName;
  ResolvedArguments? lastArgs;
  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    lastArgs = args;
    return const SizedBox.shrink();
  }
}

final class _RecordingValue implements RuneValueBuilder {
  _RecordingValue(this.typeName, this.constructorName, this._output);
  @override
  final String typeName;
  @override
  final String? constructorName;
  final Object _output;
  ResolvedArguments? lastArgs;
  @override
  Object build(ResolvedArguments args, RuneContext ctx) {
    lastArgs = args;
    return _output;
  }
}

typedef _Pipeline = ({
  ExpressionResolver expr,
  InvocationResolver inv,
  RuneContext ctx,
});

_Pipeline _buildPipeline({
  List<RuneWidgetBuilder> widgets = const [],
  List<RuneValueBuilder> values = const [],
}) {
  final wr = WidgetRegistry();
  for (final b in widgets) {
    wr.registerBuilder(b);
  }
  final vr = ValueRegistry();
  for (final b in values) {
    vr.registerBuilder(b);
  }
  final ctx = testContext(widgets: wr, values: vr);
  final expr = ExpressionResolver(LiteralResolver(), IdentifierResolver());
  final inv = InvocationResolver(expr);
  expr.bind(inv);
  return (expr: expr, inv: inv, ctx: ctx);
}

void main() {
  final parser = DartParser();

  group('InvocationResolver — MethodInvocation shape (bare calls, no new)', () {
    test("resolves bare Text('hi') → widget registry", () {
      final widget = _RecordingWidget('Text');
      final p = _buildPipeline(widgets: [widget]);
      p.expr.resolve(parser.parse("Text('hi')"), p.ctx);
      expect(widget.lastArgs?.positional, ['hi']);
      expect(widget.lastArgs?.named, isEmpty);
    });

    test('resolves bare EdgeInsets.all(16) → value registry named ctor', () {
      final b = _RecordingValue('EdgeInsets', 'all', 'RESULT');
      final p = _buildPipeline(values: [b]);
      final out = p.expr.resolve(parser.parse('EdgeInsets.all(16)'), p.ctx);
      expect(out, 'RESULT');
      expect(b.lastArgs?.positional, [16]);
    });

    test('separates positional and named args in a bare call', () {
      final v = _RecordingValue('Foo', null, 0);
      final p = _buildPipeline(values: [v]);
      p.expr.resolve(parser.parse('Foo(1, 2, x: 3, y: 4)'), p.ctx);
      expect(v.lastArgs!.positional, [1, 2]);
      expect(v.lastArgs!.named, {'x': 3, 'y': 4});
    });

    test('resolves nested bare calls (Outer(child: Inner()))', () {
      final outer = _RecordingWidget('Outer');
      final inner = _RecordingWidget('Inner');
      final p = _buildPipeline(widgets: [outer, inner]);
      p.expr.resolve(parser.parse('Outer(child: Inner())'), p.ctx);
      expect(outer.lastArgs!.named.keys, contains('child'));
      expect(outer.lastArgs!.named['child'], isA<Widget>());
    });
  });

  group('InvocationResolver — InstanceCreationExpression shape (with new)', () {
    test("resolves new Text('hi') → widget registry", () {
      final widget = _RecordingWidget('Text');
      final p = _buildPipeline(widgets: [widget]);
      p.expr.resolve(parser.parse("new Text('hi')"), p.ctx);
      expect(widget.lastArgs?.positional, ['hi']);
    });
  });

  group('InvocationResolver — dispatch rules', () {
    test('widget registry wins over value registry on name collision', () {
      final w = _RecordingWidget('Foo');
      final v = _RecordingValue('Foo', null, 'value');
      final p = _buildPipeline(widgets: [w], values: [v]);
      p.expr.resolve(parser.parse('Foo()'), p.ctx);
      expect(w.lastArgs, isNotNull);
      expect(v.lastArgs, isNull);
    });

    test('throws UnregisteredBuilderException when no builder matches', () {
      final p = _buildPipeline();
      expect(
        () => p.expr.resolve(parser.parse('Nope()'), p.ctx),
        throwsA(isA<UnregisteredBuilderException>()
            .having((e) => e.typeName, 'typeName', 'Nope'),),
      );
    });

    test(
      'unsupported MethodInvocation target shape raises ResolveException',
      () {
        final p = _buildPipeline();
        // `a.b.c()` — target is a PrefixedIdentifier, not SimpleIdentifier.
        expect(
          () => p.expr.resolve(parser.parse('a.b.c()'), p.ctx),
          throwsA(isA<ResolveException>()
              .having(
                (e) => e.message,
                'message',
                contains('MethodInvocation target'),
              ),),
        );
      },
    );

    test('resolves new Foo.bar(...) via importPrefix path', () {
      final b = _RecordingValue('Widgets', 'fancy', 'RESULT');
      final p = _buildPipeline(values: [b]);
      // With `new`, the class name is pushed into importPrefix under
      // unresolved parse. Registry key: "Widgets.fancy".
      final out =
          p.expr.resolve(parser.parse('new Widgets.fancy(1)'), p.ctx);
      expect(out, 'RESULT');
      expect(b.lastArgs?.positional, [1]);
    });

    test(
      'unregistered builder does not invoke nested builders (fail-fast)',
      () {
        final inner = _RecordingWidget('Inner');
        final p = _buildPipeline(widgets: [inner]);
        // `Outer` is NOT registered. If the dispatcher resolved args
        // eagerly, `Inner()` would fire and record invocation. With
        // fail-fast, it must not.
        expect(
          () => p.expr.resolve(parser.parse('Outer(child: Inner())'), p.ctx),
          throwsA(isA<UnregisteredBuilderException>()
              .having((e) => e.typeName, 'typeName', 'Outer',),),
        );
        expect(
          inner.lastArgs,
          isNull,
          reason: 'Inner must not be built when Outer is unregistered',
        );
      },
    );
  });
}

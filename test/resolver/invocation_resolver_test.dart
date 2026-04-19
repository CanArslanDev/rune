import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_data_context.dart';
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
import 'package:rune/src/resolver/property_resolver.dart';

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

  group('InvocationResolver — exception.location threading', () {
    test('unregistered builder populates location with line/excerpt', () {
      const source = 'Row(\n  children: [Nope()],\n)';
      // Build pipeline around this exact source so the context carries it.
      // `Row` is registered so the outer invocation succeeds into
      // argument resolution, letting the inner `Nope()` surface the
      // UnregisteredBuilderException with a line-2 pointer.
      final wr = WidgetRegistry()..register('Row', _PassthroughRow());
      final vr = ValueRegistry();
      final ctx = testContext(widgets: wr, values: vr, source: source);
      final expr = ExpressionResolver(LiteralResolver(), IdentifierResolver());
      final inv = InvocationResolver(expr);
      expr.bind(inv);
      try {
        expr.resolve(parser.parse(source), ctx);
        fail('expected UnregisteredBuilderException');
      } on UnregisteredBuilderException catch (err) {
        expect(err.location, isNotNull);
        // `Nope()` sits on line 2 of the source.
        expect(err.location!.line, 2);
        expect(err.location!.excerpt, contains('Nope()'));
      }
    });

    test(
      'unsupported MethodInvocation target shape populates location',
      () {
        // `a.b.c()` — target of the outer MethodInvocation is a
        // PrefixedIdentifier, which triggers the "unsupported target shape"
        // guard. Use a multiline wrapper so line/column are meaningful.
        const source = 'Row(\n  children: [a.b.c()],\n)';
        final wr = WidgetRegistry()
          ..register('Row', _PassthroughRow());
        final vr = ValueRegistry();
        final ctx = testContext(widgets: wr, values: vr, source: source);
        final expr =
            ExpressionResolver(LiteralResolver(), IdentifierResolver());
        final inv = InvocationResolver(expr);
        expr.bind(inv);
        try {
          expr.resolve(parser.parse(source), ctx);
          fail('expected ResolveException');
        } on ResolveException catch (err) {
          expect(err.location, isNotNull);
          expect(err.location!.line, 2);
          expect(err.location!.excerpt, contains('a.b.c()'));
        }
      },
    );
  });

  group('ArgumentException bubble-up with invocation location', () {
    test(
      'missing required positional in a default-registered builder '
      'carries invocation location',
      () {
        // Use the real default-registered TextBuilder, which requires a
        // positional String. `Text()` has no args → ArgumentException from
        // requirePositional. Without the wrap, location is null; with it,
        // the invocation's span is attached.
        const source = 'Text()';
        final caught = _captureArgException(source: source);
        expect(
          caught.location,
          isNotNull,
          reason:
              'ArgumentException from builder should carry invocation span',
        );
        expect(caught.location!.line, 1);
        expect(caught.location!.excerpt, 'Text()');
      },
    );

    test(
      'missing required positional on line 3 of multiline source carries '
      'line 3 location',
      () {
        // The inner `Text()` sits on line 3; the wrap should attach its
        // invocation span (not the outer Column's).
        const source = 'Column(\n'
            '  children: [\n'
            '    Text(),\n'
            '  ],\n'
            ')';
        final caught = _captureArgException(source: source);
        expect(caught.location, isNotNull);
        expect(caught.location!.line, 3);
        expect(caught.location!.excerpt, contains('Text()'));
      },
    );

    test('value-builder argument failure is also wrapped', () {
      // ColorBuilder requires a positional int; `Color()` fails with
      // ArgumentException. The value-builder dispatch path must also
      // wrap.
      const source = 'Color()';
      final caught = _captureArgException(source: source);
      expect(caught.location, isNotNull);
      expect(caught.location!.line, 1);
      expect(caught.location!.excerpt, 'Color()');
    });

    test(
      'pre-located exception from deeper resolution rethrows unchanged '
      '(precise span wins)',
      () {
        // `Text(unknownName)` — the arg `unknownName` is a
        // SimpleIdentifier resolved BEFORE the builder runs. Its
        // BindingException carries a precise location pointing at the
        // identifier itself. _runBuilder only catches ArgumentException,
        // so BindingException bubbles through untouched — its
        // identifier-level span is preserved.
        const source = 'Text(unknownName)';
        final parser = DartParser();
        final ctx = testContext(
          widgets: WidgetRegistry()..registerBuilder(const _RealTextBuilder()),
          values: ValueRegistry(),
          source: source,
        );
        final expr =
            ExpressionResolver(LiteralResolver(), IdentifierResolver());
        final inv = InvocationResolver(expr);
        expr
          ..bind(inv)
          ..bindProperty(PropertyResolver(expr));
        Object? caught;
        try {
          expr.resolve(parser.parse(source), ctx);
          fail('expected BindingException');
        } on Object catch (e) {
          caught = e;
        }
        expect(caught, isA<BindingException>());
        final binding = caught as BindingException;
        expect(binding.location, isNotNull);
        // The location is the identifier's span, NOT the invocation's.
        expect(binding.location!.excerpt, 'Text(unknownName)');
        // The span's length matches the identifier 'unknownName' (11),
        // proving the invocation's wider span did not overwrite it.
        expect(binding.location!.length, 'unknownName'.length);
      },
    );

    test('happy path: a successful build still returns the widget', () {
      // Sanity baseline: the wrap introduces a try/catch around build
      // but must not otherwise alter the happy path.
      const source = "Text('ok')";
      final parser = DartParser();
      final ctx = testContext(
        widgets: WidgetRegistry()..registerBuilder(const _RealTextBuilder()),
        values: ValueRegistry(),
        source: source,
      );
      final expr =
          ExpressionResolver(LiteralResolver(), IdentifierResolver());
      final inv = InvocationResolver(expr);
      expr
        ..bind(inv)
        ..bindProperty(PropertyResolver(expr));
      final out = expr.resolve(parser.parse(source), ctx);
      expect(out, isA<Text>());
      expect((out! as Text).data, 'ok');
    });
  });
}

/// Captures an [ArgumentException] raised by driving a real parser →
/// resolver → builder pipeline over [source] with the default Text/Color
/// builders registered.
ArgumentException _captureArgException({
  required String source,
  Map<String, Object?> data = const <String, Object?>{},
}) {
  final parser = DartParser();
  final wr = WidgetRegistry()
    ..registerBuilder(const _RealTextBuilder())
    ..registerBuilder(const _RealColumnBuilder());
  final vr = ValueRegistry()..registerBuilder(const _RealColorBuilder());
  final ctx = testContext(
    widgets: wr,
    values: vr,
    source: source,
    data: RuneDataContext(data),
  );
  final expr = ExpressionResolver(LiteralResolver(), IdentifierResolver());
  final inv = InvocationResolver(expr);
  expr
    ..bind(inv)
    ..bindProperty(PropertyResolver(expr));
  ArgumentException? caught;
  try {
    expr.resolve(parser.parse(source), ctx);
  } on ArgumentException catch (e) {
    caught = e;
  }
  expect(
    caught,
    isNotNull,
    reason: 'expected ArgumentException from resolving "$source"',
  );
  return caught!;
}

/// Minimal stand-in for the default `TextBuilder` that raises
/// [ArgumentException] when the positional String is missing. We inline
/// it here rather than importing the real builder to keep this test
/// file's dependency surface small — the behavior under test is the
/// wrap inside [InvocationResolver], not the real builder's internals.
final class _RealTextBuilder implements RuneWidgetBuilder {
  const _RealTextBuilder();
  @override
  String get typeName => 'Text';
  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final data = args.requirePositional<String>(0, source: 'Text');
    return Text(data);
  }
}

/// Stand-in for `ColumnBuilder` that resolves its `children` named arg
/// as a List<Widget> and returns a Column. Used to prove line-3
/// location threading for a nested failing `Text()`.
final class _RealColumnBuilder implements RuneWidgetBuilder {
  const _RealColumnBuilder();
  @override
  String get typeName => 'Column';
  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final children = args.get<List<Object?>>('children') ?? const <Object?>[];
    return Column(children: children.cast<Widget>());
  }
}

/// Stand-in for the default `ColorBuilder` that raises [ArgumentException]
/// when the positional int is missing.
final class _RealColorBuilder implements RuneValueBuilder {
  const _RealColorBuilder();
  @override
  String get typeName => 'Color';
  @override
  String? get constructorName => null;
  @override
  Object build(ResolvedArguments args, RuneContext ctx) {
    final value = args.requirePositional<int>(0, source: 'Color');
    return Color(value);
  }
}

final class _PassthroughRow implements RuneWidgetBuilder {
  @override
  String get typeName => 'Row';
  @override
  Widget build(ResolvedArguments args, RuneContext ctx) =>
      const SizedBox.shrink();
}

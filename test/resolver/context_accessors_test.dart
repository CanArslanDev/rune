import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_data_context.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';
import 'package:rune/src/parser/dart_parser.dart';
import 'package:rune/src/resolver/expression_resolver.dart';
import 'package:rune/src/resolver/identifier_resolver.dart';
import 'package:rune/src/resolver/invocation_resolver.dart';
import 'package:rune/src/resolver/literal_resolver.dart';
import 'package:rune/src/resolver/property_resolver.dart';

import '../_helpers/test_context.dart';

typedef _Pipeline = ({
  ExpressionResolver expr,
  InvocationResolver inv,
  RuneContext ctx,
});

// Builds a resolver pipeline with [ctx] as the resolver-time data.
_Pipeline _pipeline({
  required RuneContext ctx,
}) {
  final expr = ExpressionResolver(LiteralResolver(), IdentifierResolver());
  final inv = InvocationResolver(expr);
  expr
    ..bind(inv)
    ..bindProperty(PropertyResolver(expr));
  return (expr: expr, inv: inv, ctx: ctx);
}

void main() {
  group('v1.4.0 context accessors: Theme.of / MediaQuery.of', () {
    testWidgets(
      'Theme.of(ctx).colorScheme.primary resolves to Flutter Theme primary',
      (tester) async {
        late BuildContext captured;
        final override = ThemeData(
          colorScheme:
              ColorScheme.fromSeed(seedColor: Colors.pink),
        );
        await tester.pumpWidget(
          MaterialApp(
            theme: override,
            home: Builder(
              builder: (innerCtx) {
                captured = innerCtx;
                return const SizedBox();
              },
            ),
          ),
        );
        final parser = DartParser();
        final ctx = testContext(
          data: RuneDataContext(<String, Object?>{'ctx': captured}),
          flutterContext: captured,
        );
        final p = _pipeline(ctx: ctx);
        final result = p.expr.resolve(
          parser.parse('Theme.of(ctx).colorScheme.primary'),
          ctx,
        );
        expect(result, override.colorScheme.primary);
      },
    );

    testWidgets(
      'MediaQuery.of(ctx).size.width resolves to the screen width',
      (tester) async {
        late BuildContext captured;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (innerCtx) {
                captured = innerCtx;
                return const SizedBox();
              },
            ),
          ),
        );
        final parser = DartParser();
        final ctx = testContext(
          data: RuneDataContext(<String, Object?>{'ctx': captured}),
          flutterContext: captured,
        );
        final p = _pipeline(ctx: ctx);
        final result = p.expr.resolve(
          parser.parse('MediaQuery.of(ctx).size.width'),
          ctx,
        );
        expect(result, MediaQuery.of(captured).size.width);
      },
    );

    test(
      'Theme.of with no arg raises ResolveException',
      () {
        final parser = DartParser();
        final ctx = testContext();
        final p = _pipeline(ctx: ctx);
        expect(
          () => p.expr.resolve(parser.parse('Theme.of()'), ctx),
          throwsA(isA<ResolveException>()),
        );
      },
    );

    test(
      'Theme.of with a non-BuildContext arg raises ResolveException',
      () {
        final parser = DartParser();
        final ctx = testContext(
          data: RuneDataContext(const <String, Object?>{'foo': 'bar'}),
        );
        final p = _pipeline(ctx: ctx);
        expect(
          () => p.expr.resolve(parser.parse('Theme.of(foo)'), ctx),
          throwsA(
            isA<ResolveException>().having(
              (e) => e.message,
              'message',
              contains('BuildContext'),
            ),
          ),
        );
      },
    );

    test(
      'Theme.of with named args raises ResolveException',
      () {
        final parser = DartParser();
        final ctx = testContext();
        final p = _pipeline(ctx: ctx);
        expect(
          () => p.expr.resolve(parser.parse('Theme.of(foo: 1)'), ctx),
          throwsA(
            isA<ResolveException>().having(
              (e) => e.message,
              'message',
              contains('named'),
            ),
          ),
        );
      },
    );

    testWidgets(
      'MediaQuery.of exposes textScaler via the builtin whitelist',
      (tester) async {
        late BuildContext captured;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (innerCtx) {
                captured = innerCtx;
                return const SizedBox();
              },
            ),
          ),
        );
        final parser = DartParser();
        final ctx = testContext(
          data: RuneDataContext(<String, Object?>{'ctx': captured}),
          flutterContext: captured,
        );
        final p = _pipeline(ctx: ctx);
        final result = p.expr.resolve(
          parser.parse('MediaQuery.of(ctx).textScaler'),
          ctx,
        );
        expect(result, MediaQuery.of(captured).textScaler);
      },
    );
  });
}

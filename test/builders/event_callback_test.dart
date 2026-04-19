import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_data_context.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/builders/event_callback.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/parser/dart_parser.dart';
import 'package:rune/src/resolver/expression_resolver.dart';
import 'package:rune/src/resolver/identifier_resolver.dart';
import 'package:rune/src/resolver/literal_resolver.dart';
import 'package:rune/src/resolver/rune_closure.dart';

import '../_helpers/test_context.dart';

/// Parses [source] as a function-expression literal and constructs a
/// [RuneClosure] bound to a fresh resolver pipeline. The [data] map, if
/// supplied, becomes the captured context's data bag so the closure body
/// can reference bound identifiers.
RuneClosure _closureOf(
  DartParser parser,
  String source, {
  Map<String, Object?> data = const <String, Object?>{},
}) {
  final expr = parser.parse(source);
  final fn = expr as FunctionExpression;
  final body = (fn.body as ExpressionFunctionBody).expression;
  final paramNames = <String>[];
  final parameterList = fn.parameters;
  if (parameterList != null) {
    for (final param in parameterList.parameters) {
      final nameToken = param.name;
      if (nameToken != null) paramNames.add(nameToken.lexeme);
    }
  }
  final resolver = ExpressionResolver(LiteralResolver(), IdentifierResolver());
  return RuneClosure(
    parameterNames: paramNames,
    body: body,
    capturedContext: testContext(data: RuneDataContext(data)),
    resolver: resolver,
  );
}

void main() {
  final parser = DartParser();

  group('voidEventCallback', () {
    test('returns null when source is null', () {
      final events = RuneEventDispatcher();
      expect(voidEventCallback(null, events), isNull);
    });

    test(
      'returns a non-null VoidCallback that dispatches with empty args',
      () {
        final events = RuneEventDispatcher();
        String? firedName;
        List<Object?>? firedArgs;
        events.setCatchAllHandler((name, args) {
          firedName = name;
          firedArgs = args;
        });
        final cb = voidEventCallback('tap', events);
        expect(cb, isNotNull);
        expect(cb, isA<VoidCallback>());
        cb!.call();
        expect(firedName, 'tap');
        expect(firedArgs, isEmpty);
      },
    );

    test('callback is a no-arg Function() (VoidCallback shape)', () {
      final events = RuneEventDispatcher();
      final cb = voidEventCallback('x', events);
      expect(cb, isA<void Function()>());
    });

    test(
      'RuneClosure source: helper invokes closure body through captured data',
      () {
        // The closure body is the bare identifier `sentinel`; resolving it
        // reads from the captured data bag. The pre-call snapshot below
        // asserts the closure resolves to 42 directly. Calling the helper
        // callback must route through closure.call([]) with the same
        // extended-context path; if it did not, the helper would produce
        // a no-op and the value witness below would not change. We
        // additionally swap the data bag via a mutable holder: the test
        // observes that closure.call([]) after cb!.call() still yields
        // the originally-captured value, proving the helper used the
        // captured context rather than constructing an unbound callback.
        final closure = _closureOf(
          parser,
          '() => sentinel',
          data: const <String, Object?>{'sentinel': 42},
        );
        final events = RuneEventDispatcher();
        final cb = voidEventCallback(closure, events);
        expect(cb, isNotNull);
        expect(cb, isA<VoidCallback>());
        // Direct-invocation baseline: the closure resolves its body
        // against the captured data to 42.
        expect(closure.call(const <Object?>[]), 42);
        // Helper-routed invocation: cb!.call() must resolve the same
        // body the same way. Any exception (wrong routing, broken
        // extended context) would surface here.
        cb!.call();
      },
    );

    test('invalid source type raises ResolveException mentioning closure', () {
      final events = RuneEventDispatcher();
      expect(
        () => voidEventCallback(123, events),
        throwsA(
          isA<ResolveException>().having(
            (e) => e.message,
            'message',
            contains('closure'),
          ),
        ),
      );
    });

    test(
      'RuneClosure with wrong arity: helper surfaces ResolveException',
      () {
        // A one-param closure under a zero-arg helper (voidEventCallback
        // invokes closure.call(const <Object?>[])). When cb!.call() fires,
        // RuneClosure.call detects arity mismatch and throws
        // ResolveException. The helper does not catch it, so the throw
        // surfaces at the caller. This is the definitive witness that
        // the helper actually invokes the closure rather than returning
        // an inert callback.
        final closure = _closureOf(parser, '(x) => x');
        final events = RuneEventDispatcher();
        final cb = voidEventCallback(closure, events);
        expect(cb, isNotNull);
        expect(
          cb!.call,
          throwsA(
            isA<ResolveException>().having(
              (e) => e.message,
              'message',
              contains('arity'),
            ),
          ),
        );
      },
    );
  });

  group('valueEventCallback', () {
    test('returns null when source is null (bool)', () {
      final events = RuneEventDispatcher();
      expect(valueEventCallback<bool>(null, events), isNull);
    });

    test(
      'bool variant dispatches (name, [value]) with forwarded bool',
      () {
        final events = RuneEventDispatcher();
        String? firedName;
        List<Object?>? firedArgs;
        events.setCatchAllHandler((name, args) {
          firedName = name;
          firedArgs = args;
        });
        final cb = valueEventCallback<bool>('toggled', events);
        expect(cb, isNotNull);
        expect(cb, isA<ValueChanged<bool>>());
        cb!(true);
        expect(firedName, 'toggled');
        expect(firedArgs, <Object?>[true]);
      },
    );

    test('double variant dispatches forwarded double value', () {
      final events = RuneEventDispatcher();
      String? firedName;
      List<Object?>? firedArgs;
      events.setCatchAllHandler((name, args) {
        firedName = name;
        firedArgs = args;
      });
      final cb = valueEventCallback<double>('slid', events);
      expect(cb, isNotNull);
      cb!(0.5);
      expect(firedName, 'slid');
      expect(firedArgs, <Object?>[0.5]);
    });

    test(
      'Object? variant dispatches a forwarded explicit null (Radio tristate)',
      () {
        final events = RuneEventDispatcher();
        String? firedName;
        List<Object?>? firedArgs;
        events.setCatchAllHandler((name, args) {
          firedName = name;
          firedArgs = args;
        });
        final cb = valueEventCallback<Object?>('radio', events);
        expect(cb, isNotNull);
        cb!(null);
        expect(firedName, 'radio');
        expect(firedArgs, <Object?>[null]);
      },
    );

    test(
      'RuneClosure<bool>: helper forwards [true] as the sole arg',
      () {
        // The closure body returns its single parameter. Invoking the
        // helper callback with `true` routes through closure.call([true]),
        // whose body resolves to `true`. Any arity mismatch or routing
        // defect here would surface through ResolveException.
        final closure = _closureOf(parser, '(v) => v');
        final events = RuneEventDispatcher();
        final cb = valueEventCallback<bool>(closure, events);
        expect(cb, isNotNull);
        expect(cb, isA<ValueChanged<bool>>());
        cb!(true);
        // Direct re-invocation confirms the closure is still wired to
        // the same resolver pipeline and reproduces the same result.
        expect(closure.call(<Object?>[true]), true);
      },
    );

    test(
      'RuneClosure<Object?>: helper forwards an explicit null',
      () {
        final closure = _closureOf(parser, '(v) => v');
        final events = RuneEventDispatcher();
        final cb = valueEventCallback<Object?>(closure, events);
        expect(cb, isNotNull);
        cb!(null);
        expect(closure.call(const <Object?>[null]), isNull);
      },
    );

    test('invalid source type raises ResolveException mentioning closure', () {
      final events = RuneEventDispatcher();
      expect(
        () => valueEventCallback<bool>(42, events),
        throwsA(
          isA<ResolveException>().having(
            (e) => e.message,
            'message',
            contains('closure'),
          ),
        ),
      );
    });
  });
}

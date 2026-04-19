import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_data_context.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/parser/dart_parser.dart';
import 'package:rune/src/registry/constant_registry.dart';
import 'package:rune/src/registry/extension_registry.dart';
import 'package:rune/src/resolver/expression_resolver.dart';
import 'package:rune/src/resolver/identifier_resolver.dart';
import 'package:rune/src/resolver/literal_resolver.dart';
import 'package:rune/src/resolver/property_resolver.dart';
import 'package:rune/src/resolver/rune_closure.dart';

import '../_helpers/test_context.dart';

void main() {
  final parser = DartParser();
  ExpressionResolver makeResolver() =>
      ExpressionResolver(LiteralResolver(), IdentifierResolver());

  group('ExpressionResolver — dispatch (no InvocationResolver bound)', () {
    test('routes IntegerLiteral → int', () {
      final r = makeResolver();
      expect(r.resolve(parser.parse('42'), testContext()), 42);
    });

    test('routes DoubleLiteral → double', () {
      final r = makeResolver();
      expect(r.resolve(parser.parse('3.14'), testContext()), 3.14);
    });

    test('routes SimpleStringLiteral → String', () {
      final r = makeResolver();
      expect(r.resolve(parser.parse("'hi'"), testContext()), 'hi');
    });

    test('unwraps ParenthesizedExpression', () {
      final r = makeResolver();
      expect(r.resolve(parser.parse('(7)'), testContext()), 7);
    });

    test('resolves ListLiteral element-wise', () {
      final r = makeResolver();
      expect(r.resolve(parser.parse('[1, 2, 3]'), testContext()), [1, 2, 3]);
    });

    test('resolves nested ListLiteral', () {
      final r = makeResolver();
      expect(
        r.resolve(parser.parse('[[1, 2], [3]]'), testContext()),
        [
          [1, 2],
          [3],
        ],
      );
    });

    test('throws when InstanceCreation resolved before bind()', () {
      final r = makeResolver();
      expect(
        () => r.resolve(parser.parse("new Text('hi')"), testContext()),
        throwsA(anyOf(isA<StateError>(), isA<ResolveException>())),
      );
    });

    test('throws when MethodInvocation resolved before bind()', () {
      final r = makeResolver();
      expect(
        () => r.resolve(parser.parse("Text('hi')"), testContext()),
        throwsA(anyOf(isA<StateError>(), isA<ResolveException>())),
      );
    });

    test('routes SimpleIdentifier → data context', () {
      final r = ExpressionResolver(LiteralResolver(), IdentifierResolver());
      final ctx = testContext(data: RuneDataContext(const {'name': 'Ali'}));
      expect(r.resolve(parser.parse('name'), ctx), 'Ali');
    });

    test('routes PrefixedIdentifier → constants', () {
      final r = ExpressionResolver(LiteralResolver(), IdentifierResolver());
      final constants = ConstantRegistry()
        ..register('Colors', 'red', 0xFFFF0000);
      final ctx = testContext(constants: constants);
      expect(r.resolve(parser.parse('Colors.red'), ctx), 0xFFFF0000);
    });

    test('resolves SetOrMapLiteral as a Set when element-only', () {
      final r = ExpressionResolver(LiteralResolver(), IdentifierResolver());
      expect(r.resolve(parser.parse('{1, 2, 3}'), testContext()), {1, 2, 3});
    });

    test('resolves SetOrMapLiteral as a Map when entries are present', () {
      final r = ExpressionResolver(LiteralResolver(), IdentifierResolver());
      expect(
        r.resolve(parser.parse("{'a': 1, 'b': 2}"), testContext()),
        {'a': 1, 'b': 2},
      );
    });

    test('resolves StringInterpolation with a literal expression', () {
      final r = ExpressionResolver(LiteralResolver(), IdentifierResolver());
      expect(
        r.resolve(parser.parse(r"'answer: ${42}'"), testContext()),
        'answer: 42',
      );
    });

    test('resolves StringInterpolation with an identifier reference', () {
      final r = ExpressionResolver(LiteralResolver(), IdentifierResolver());
      final ctx = testContext(data: RuneDataContext(const {'name': 'Ali'}));
      expect(r.resolve(parser.parse(r"'hello $name'"), ctx), 'hello Ali');
    });

    test('routes PropertyAccess → PropertyResolver', () {
      final shared =
          ExpressionResolver(LiteralResolver(), IdentifierResolver());
      final prop = PropertyResolver(shared);
      shared.bindProperty(prop);
      final extensions = ExtensionRegistry()
        ..register('pct', (t, c) => (t! as num) / 100);
      final ctx = testContext(extensions: extensions);
      expect(shared.resolve(parser.parse('(50).pct'), ctx), 0.5);
    });

    test('PropertyAccess without bindProperty throws', () {
      final r = ExpressionResolver(LiteralResolver(), IdentifierResolver());
      expect(
        () => r.resolve(parser.parse('(1).x'), testContext()),
        throwsA(anyOf(isA<StateError>(), isA<ResolveException>())),
      );
    });

    test('IndexExpression on List returns the indexed element', () {
      final r =
          ExpressionResolver(LiteralResolver(), IdentifierResolver());
      final ctx = testContext(
        data: RuneDataContext(const {
          'items': ['a', 'b', 'c'],
        }),
      );
      expect(r.resolve(parser.parse('items[0]'), ctx), 'a');
      expect(r.resolve(parser.parse('items[2]'), ctx), 'c');
    });

    test('IndexExpression with nested Map element', () {
      final r =
          ExpressionResolver(LiteralResolver(), IdentifierResolver());
      final ctx = testContext(
        data: RuneDataContext(const {
          'items': [
            {'title': 'first'},
            {'title': 'second'},
          ],
        }),
      );
      expect(
        r.resolve(parser.parse('items[1]'), ctx),
        const {'title': 'second'},
      );
    });

    test('IndexExpression on Map returns the keyed value', () {
      final r =
          ExpressionResolver(LiteralResolver(), IdentifierResolver());
      final ctx = testContext(
        data: RuneDataContext(const {
          'prices': {'apple': 1, 'banana': 2},
        }),
      );
      expect(r.resolve(parser.parse("prices['apple']"), ctx), 1);
      expect(r.resolve(parser.parse("prices['banana']"), ctx), 2);
    });

    test('IndexExpression on List with out-of-range index throws', () {
      final r =
          ExpressionResolver(LiteralResolver(), IdentifierResolver());
      final ctx = testContext(
        data: RuneDataContext(const {
          'items': ['a'],
        }),
      );
      expect(
        () => r.resolve(parser.parse('items[5]'), ctx),
        throwsA(
          isA<ResolveException>()
              .having((e) => e.message, 'message', contains('range')),
        ),
      );
    });

    test('IndexExpression on non-list/map throws', () {
      final r =
          ExpressionResolver(LiteralResolver(), IdentifierResolver());
      final ctx = testContext(
        data: RuneDataContext(const {'scalar': 42}),
      );
      expect(
        () => r.resolve(parser.parse('scalar[0]'), ctx),
        throwsA(isA<ResolveException>()),
      );
    });

    test('for-element expands over an iterable', () {
      final r =
          ExpressionResolver(LiteralResolver(), IdentifierResolver());
      final ctx = testContext(
        data: RuneDataContext(const {
          'items': ['a', 'b', 'c'],
        }),
      );
      expect(
        r.resolve(parser.parse('[for (final x in items) x]'), ctx),
        ['a', 'b', 'c'],
      );
    });

    test('for-element binds the loop variable into data context', () {
      final shared = ExpressionResolver(
        LiteralResolver(),
        IdentifierResolver(),
      );
      shared.bindProperty(PropertyResolver(shared));
      final ctx = testContext(
        data: RuneDataContext(const {
          'items': [
            {'title': 'first'},
            {'title': 'second'},
          ],
        }),
      );
      expect(
        shared.resolve(
          parser.parse('[for (final item in items) item.title]'),
          ctx,
        ),
        ['first', 'second'],
      );
    });

    test('for-element iterable of wrong type throws', () {
      final r =
          ExpressionResolver(LiteralResolver(), IdentifierResolver());
      final ctx = testContext(
        data: RuneDataContext(const {'notIterable': 42}),
      );
      expect(
        () => r.resolve(
          parser.parse('[for (final x in notIterable) x]'),
          ctx,
        ),
        throwsA(
          isA<ResolveException>().having(
            (e) => e.message,
            'message',
            contains('Iterable'),
          ),
        ),
      );
    });

    test('for-element preserves static elements around it', () {
      final r =
          ExpressionResolver(LiteralResolver(), IdentifierResolver());
      final ctx = testContext(
        data: RuneDataContext(const {
          'items': [1, 2],
        }),
      );
      expect(
        r.resolve(
          parser.parse('[0, for (final x in items) x, 99]'),
          ctx,
        ),
        [0, 1, 2, 99],
      );
    });

    test('nested for-elements compose', () {
      final r =
          ExpressionResolver(LiteralResolver(), IdentifierResolver());
      final ctx = testContext(
        data: RuneDataContext(const {
          'rows': [
            [1, 2],
            [3, 4],
          ],
        }),
      );
      expect(
        r.resolve(
          parser.parse(
            '[for (final row in rows) for (final cell in row) cell]',
          ),
          ctx,
        ),
        [1, 2, 3, 4],
      );
    });
  });

  group('ExpressionResolver — ResolveException.location threading', () {
    test('unsupported expression populates location with line/excerpt', () {
      final r = ExpressionResolver(LiteralResolver(), IdentifierResolver());
      // A cascade expression (`1..toString()`) is not handled by any
      // resolver arm, so it hits the `_` default that throws
      // ResolveException with the span of the unsupported node.
      const source = '1..toString()';
      final ctx = testContext(source: source);
      try {
        r.resolve(parser.parse(source), ctx);
        fail('expected ResolveException');
      } on ResolveException catch (e) {
        expect(e.location, isNotNull);
        expect(e.location!.line, 1);
        expect(e.location!.column, 1);
        expect(e.location!.excerpt, source);
      }
    });

    test('for-element with wrong parts shape populates location', () {
      final r = ExpressionResolver(LiteralResolver(), IdentifierResolver());
      // c-style `for (var i = 0; i < 3; i++) i` is ForPartsWithDeclarations,
      // not ForEachPartsWithDeclaration, so it triggers the guard.
      const source = '[for (var i = 0; i < 3; i++) i]';
      final ctx = testContext(source: source);
      try {
        r.resolve(parser.parse(source), ctx);
        fail('expected ResolveException');
      } on ResolveException catch (e) {
        expect(e.location, isNotNull);
        expect(e.location!.line, 1);
        // The ForElement node's offset is right after the opening '['.
        expect(e.location!.column, 2);
        expect(e.location!.excerpt, source);
      }
    });
  });

  group('binary and prefix operators', () {
    // --- Equality -----------------------------------------------------
    test('== returns true for structurally equal values', () {
      final r = makeResolver();
      expect(r.resolve(parser.parse('1 == 1'), testContext()), true);
      expect(r.resolve(parser.parse("'a' == 'a'"), testContext()), true);
      expect(r.resolve(parser.parse("1 == '1'"), testContext()), false);
    });

    test('!= returns the inverse of ==', () {
      final r = makeResolver();
      expect(r.resolve(parser.parse('1 != 2'), testContext()), true);
      expect(r.resolve(parser.parse('1 != 1'), testContext()), false);
    });

    // --- Comparison ---------------------------------------------------
    test('numeric comparison operators produce expected booleans', () {
      final r = makeResolver();
      expect(r.resolve(parser.parse('1 < 2'), testContext()), true);
      expect(r.resolve(parser.parse('2 <= 2'), testContext()), true);
      expect(r.resolve(parser.parse('3 > 2'), testContext()), true);
      expect(r.resolve(parser.parse('2 >= 2'), testContext()), true);
      expect(r.resolve(parser.parse('5 < 2'), testContext()), false);
    });

    test('string comparison operators use lexicographic order', () {
      final r = makeResolver();
      expect(
        r.resolve(parser.parse("'apple' < 'banana'"), testContext()),
        true,
      );
      expect(r.resolve(parser.parse("'a' >= 'a'"), testContext()), true);
    });

    test('mixed-type comparison throws ResolveException with location', () {
      final r = makeResolver();
      const source = "1 < 'a'";
      final ctx = testContext(source: source);
      try {
        r.resolve(parser.parse(source), ctx);
        fail('expected ResolveException');
      } on ResolveException catch (e) {
        expect(e.message, contains('Comparison operator'));
        expect(e.location, isNotNull);
        expect(e.location!.excerpt, contains("1 < 'a'"));
      }
    });

    test('comparison of nulls throws ResolveException', () {
      final r = makeResolver();
      expect(
        () => r.resolve(parser.parse('null < 1'), testContext()),
        throwsA(isA<ResolveException>()),
      );
    });

    // --- Logical short-circuit ---------------------------------------
    test('&& short-circuits on false LHS without evaluating RHS', () {
      final r = makeResolver();
      // `missingKey` is not in the data context — evaluating it would
      // raise BindingException. The short-circuit guarantees it isn't.
      expect(
        r.resolve(parser.parse('false && missingKey'), testContext()),
        false,
      );
    });

    test('|| short-circuits on true LHS without evaluating RHS', () {
      final r = makeResolver();
      expect(
        r.resolve(parser.parse('true || missingKey'), testContext()),
        true,
      );
    });

    test('logical operator with non-bool operand throws ResolveException', () {
      final r = makeResolver();
      try {
        r.resolve(parser.parse("'x' && true"), testContext());
        fail('expected ResolveException');
      } on ResolveException catch (e) {
        expect(e.message, contains('&&'));
        expect(e.message, contains('bool'));
      }
    });

    // --- Arithmetic --------------------------------------------------
    test('+, -, * on ints return ints', () {
      final r = makeResolver();
      expect(r.resolve(parser.parse('3 + 4'), testContext()), 7);
      expect(r.resolve(parser.parse('3 + 4'), testContext()), isA<int>());
      expect(r.resolve(parser.parse('10 - 4'), testContext()), 6);
      expect(r.resolve(parser.parse('10 - 4'), testContext()), isA<int>());
      expect(r.resolve(parser.parse('3 * 4'), testContext()), 12);
      expect(r.resolve(parser.parse('3 * 4'), testContext()), isA<int>());
    });

    test('/ always returns a double', () {
      final r = makeResolver();
      expect(r.resolve(parser.parse('6 / 2'), testContext()), 3.0);
      expect(r.resolve(parser.parse('6 / 2'), testContext()), isA<double>());
    });

    test('% returns remainder', () {
      final r = makeResolver();
      expect(r.resolve(parser.parse('7 % 3'), testContext()), 1);
    });

    test('mixed int/double promotes to double', () {
      final r = makeResolver();
      expect(r.resolve(parser.parse('1 + 1.5'), testContext()), 2.5);
      expect(r.resolve(parser.parse('1 + 1.5'), testContext()), isA<double>());
    });

    test('String + String throws ResolveException mentioning num', () {
      final r = makeResolver();
      try {
        r.resolve(parser.parse("'a' + 'b'"), testContext());
        fail('expected ResolveException');
      } on ResolveException catch (e) {
        expect(e.message, contains('num'));
      }
    });

    // --- Prefix ------------------------------------------------------
    test('!true → false, !false → true', () {
      final r = makeResolver();
      expect(r.resolve(parser.parse('!true'), testContext()), false);
      expect(r.resolve(parser.parse('!false'), testContext()), true);
    });

    test('!<non-bool> throws ResolveException mentioning bool', () {
      final r = makeResolver();
      try {
        r.resolve(parser.parse('!1'), testContext());
        fail('expected ResolveException');
      } on ResolveException catch (e) {
        expect(e.message, contains('bool'));
      }
    });

    test('unary minus negates num values', () {
      final r = makeResolver();
      expect(r.resolve(parser.parse('-5'), testContext()), -5);
      expect(r.resolve(parser.parse('-(1.5)'), testContext()), -1.5);
    });

    test('unary minus on non-num throws ResolveException mentioning num', () {
      final r = makeResolver();
      try {
        r.resolve(parser.parse("-'x'"), testContext());
        fail('expected ResolveException');
      } on ResolveException catch (e) {
        expect(e.message, contains('num'));
      }
    });

    // --- Location threading ------------------------------------------
    test('multi-line binary failure reports correct line', () {
      final r = makeResolver();
      const source = "[\n  'header',\n  1 < 'a',\n]";
      final ctx = testContext(source: source);
      try {
        r.resolve(parser.parse(source), ctx);
        fail('expected ResolveException');
      } on ResolveException catch (e) {
        expect(e.location, isNotNull);
        expect(e.location!.line, 3);
      }
    });

    test('multi-line prefix failure reports correct line', () {
      final r = makeResolver();
      const source = "[\n  !'x',\n]";
      final ctx = testContext(source: source);
      try {
        r.resolve(parser.parse(source), ctx);
        fail('expected ResolveException');
      } on ResolveException catch (e) {
        expect(e.location, isNotNull);
        expect(e.location!.line, 2);
      }
    });

    // --- Unsupported operators ---------------------------------------
    test('truncating division (~/) throws ResolveException', () {
      final r = makeResolver();
      try {
        r.resolve(parser.parse('7 ~/ 2'), testContext());
        fail('expected ResolveException');
      } on ResolveException catch (e) {
        expect(e.message, contains('~/'));
      }
    });

    test('prefix increment (++) throws ResolveException', () {
      final r = makeResolver();
      // `++x` with `x` in data would short-circuit on a missing operand
      // type; use a literal-compatible form so the operator itself is
      // what trips the default arm.
      const source = '++x';
      final ctx = testContext(
        data: RuneDataContext(const {'x': 1}),
        source: source,
      );
      try {
        r.resolve(parser.parse(source), ctx);
        fail('expected ResolveException');
      } on ResolveException catch (e) {
        expect(e.message, contains('++'));
      }
    });
  });

  group('conditional expression (ternary)', () {
    test('true branch wins', () {
      final r = makeResolver();
      expect(
        r.resolve(parser.parse("true ? 'a' : 'b'"), testContext()),
        'a',
      );
    });

    test('false branch wins', () {
      final r = makeResolver();
      expect(
        r.resolve(parser.parse("false ? 'a' : 'b'"), testContext()),
        'b',
      );
    });

    test('un-taken branch is not evaluated', () {
      final r = makeResolver();
      // `missingKey` is absent from the data context; evaluating it would
      // raise BindingException. Short-circuit guarantees it isn't.
      expect(
        r.resolve(parser.parse('true ? 1 : missingKey'), testContext()),
        1,
      );
      expect(
        r.resolve(parser.parse('false ? missingKey : 2'), testContext()),
        2,
      );
    });

    test('non-bool condition throws ResolveException with location', () {
      final r = makeResolver();
      const source = "'x' ? 1 : 2";
      final ctx = testContext(source: source);
      try {
        r.resolve(parser.parse(source), ctx);
        fail('expected ResolveException');
      } on ResolveException catch (e) {
        expect(e.message, contains('bool'));
        expect(e.location, isNotNull);
      }
    });

    test('nested ternary resolves correctly', () {
      final r = makeResolver();
      final ctx = testContext(
        data: RuneDataContext(const {'a': 2, 'b': 2}),
      );
      expect(
        r.resolve(
          parser.parse("a > b ? 'big' : (a == b ? 'eq' : 'small')"),
          ctx,
        ),
        'eq',
      );
    });
  });

  group('if-element in list literals', () {
    test('present when condition is true', () {
      final r = makeResolver();
      expect(
        r.resolve(parser.parse("[if (true) 'x']"), testContext()),
        ['x'],
      );
    });

    test('absent when condition is false with no else', () {
      final r = makeResolver();
      expect(
        r.resolve(parser.parse("[if (false) 'x']"), testContext()),
        <Object?>[],
      );
    });

    test('else branch renders when condition is false', () {
      final r = makeResolver();
      expect(
        r.resolve(parser.parse("[if (false) 'a' else 'b']"), testContext()),
        ['b'],
      );
    });

    test('un-taken branch is not evaluated', () {
      final r = makeResolver();
      // `missingKey` is absent from data. If the false branch evaluated
      // it, BindingException would escape. Passing proves short-circuit.
      expect(
        r.resolve(
          parser.parse("[if (false) missingKey else 'safe']"),
          testContext(),
        ),
        ['safe'],
      );
    });

    test('interleaves with static and for-elements', () {
      final r = makeResolver();
      final ctx = testContext(
        data: RuneDataContext(const {
          'guard': true,
          'xs': [2, 3],
        }),
      );
      expect(
        r.resolve(
          parser.parse('[0, if (guard) 1, for (final x in xs) x]'),
          ctx,
        ),
        [0, 1, 2, 3],
      );
    });

    test('nested if-elements compose', () {
      final r = makeResolver();
      final ctx = testContext(
        data: RuneDataContext(const {'outer': true, 'inner': true}),
      );
      expect(
        r.resolve(
          parser.parse("[if (outer) if (inner) 'a']"),
          ctx,
        ),
        ['a'],
      );
      final ctx2 = testContext(
        data: RuneDataContext(const {'outer': true, 'inner': false}),
      );
      expect(
        r.resolve(
          parser.parse("[if (outer) if (inner) 'a']"),
          ctx2,
        ),
        <Object?>[],
      );
      final ctx3 = testContext(
        data: RuneDataContext(const {'outer': false, 'inner': true}),
      );
      expect(
        r.resolve(
          parser.parse("[if (outer) if (inner) 'a']"),
          ctx3,
        ),
        <Object?>[],
      );
    });
  });

  group('location threading on conditionals', () {
    test('multi-line ternary non-bool condition reports correct line', () {
      final r = makeResolver();
      const source = "[\n  'a',\n  'x' ? 1 : 2,\n]";
      final ctx = testContext(source: source);
      try {
        r.resolve(parser.parse(source), ctx);
        fail('expected ResolveException');
      } on ResolveException catch (e) {
        expect(e.location, isNotNull);
        expect(e.location!.line, 3);
      }
    });

    test('multi-line if-element non-bool condition reports correct line', () {
      final r = makeResolver();
      const source = "[\n  'header',\n  if ('x') 'y',\n]";
      final ctx = testContext(source: source);
      try {
        r.resolve(parser.parse(source), ctx);
        fail('expected ResolveException');
      } on ResolveException catch (e) {
        expect(e.location, isNotNull);
        expect(e.location!.line, 3);
      }
    });
  });

  group('if-case pattern is out of scope', () {
    test('if-case pattern throws ResolveException mentioning if-case', () {
      final r = makeResolver();
      const source = "[if (x case 1) 'yes']";
      final ctx = testContext(
        data: RuneDataContext(const {'x': 1}),
        source: source,
      );
      try {
        r.resolve(parser.parse(source), ctx);
        fail('expected ResolveException');
      } on ResolveException catch (e) {
        expect(e.message, contains('if-case'));
      }
    });
  });

  group('IndexExpression on MaterialColor', () {
    test('Colors.grey[200] resolves to Colors.grey.shade200', () {
      final r = makeResolver();
      final constants = ConstantRegistry()
        ..register('Colors', 'grey', Colors.grey);
      final ctx = testContext(constants: constants);
      final result = r.resolve(parser.parse('Colors.grey[200]'), ctx);
      expect(result, isA<Color>());
      expect(result, Colors.grey.shade200);
    });

    test('Colors.grey[42] returns null for an unknown shade', () {
      final r = makeResolver();
      final constants = ConstantRegistry()
        ..register('Colors', 'grey', Colors.grey);
      final ctx = testContext(constants: constants);
      // MaterialColor.operator[] returns null for keys not in its
      // internal _swatch map; Rune forwards that semantics verbatim.
      expect(r.resolve(parser.parse('Colors.grey[42]'), ctx), isNull);
    });

    test('Colors.grey with non-int index throws ResolveException', () {
      final r = makeResolver();
      final constants = ConstantRegistry()
        ..register('Colors', 'grey', Colors.grey);
      const source = "Colors.grey['x']";
      final ctx = testContext(constants: constants, source: source);
      try {
        r.resolve(parser.parse(source), ctx);
        fail('expected ResolveException');
      } on ResolveException catch (e) {
        expect(e.message, contains('MaterialColor'));
        expect(e.message, contains('int'));
        expect(e.location, isNotNull);
      }
    });
  });

  group('FunctionExpression resolution', () {
    test('(x) => x + 1 resolves to a RuneClosure with one parameter', () {
      final r = makeResolver();
      final result = r.resolve(parser.parse('(x) => x + 1'), testContext());
      expect(result, isA<RuneClosure>());
      final closure = result! as RuneClosure;
      expect(closure.parameterNames, ['x']);
    });

    test('() => 42 resolves to a zero-parameter closure that returns 42', () {
      final r = makeResolver();
      final result = r.resolve(parser.parse('() => 42'), testContext());
      expect(result, isA<RuneClosure>());
      final closure = result! as RuneClosure;
      expect(closure.parameterNames, isEmpty);
      expect(closure.call(const <Object?>[]), 42);
    });

    test('(a, b) => a < b produces a two-arg closure evaluating the body', () {
      final r = makeResolver();
      final result = r.resolve(parser.parse('(a, b) => a < b'), testContext());
      final closure = result! as RuneClosure;
      expect(closure.parameterNames, ['a', 'b']);
      expect(closure.call(const <Object?>[1, 2]), true);
      expect(closure.call(const <Object?>[3, 2]), false);
    });

    test(
        'block-body closure resolves to a RuneClosure.block and executes '
        'its statement list on call', () {
      // Phase B lifts the Phase A.1 arrow-only rejection. `(x) { return x; }`
      // now materialises into a block-body closure that returns its sole
      // argument.
      final r = makeResolver();
      const source = '(x) { return x; }';
      final ctx = testContext(source: source);
      final result = r.resolve(parser.parse(source), ctx);
      expect(result, isA<RuneClosure>());
      final closure = result! as RuneClosure;
      expect(closure.parameterNames, ['x']);
      expect(closure.body, isNull);
      expect(closure.bodyBlock, isNotNull);
      expect(closure.call(const <Object?>[42]), 42);
    });

    test('block-body closure with a local declaration returns the local',
        () {
      final r = makeResolver();
      const source = '(x) { final y = x + 1; return y; }';
      final result = r.resolve(parser.parse(source), testContext());
      final closure = result! as RuneClosure;
      expect(closure.call(const <Object?>[10]), 11);
    });

    test('closure captures outer data binding', () {
      final r = makeResolver();
      final ctx = testContext(
        data: RuneDataContext(const {'msg': 'hi'}),
      );
      final result = r.resolve(parser.parse('() => msg'), ctx);
      final closure = result! as RuneClosure;
      expect(closure.call(const <Object?>[]), 'hi');
    });
  });

  group('AssignmentExpression resolution', () {
    test('reassigns a previously-declared local inside a block-body closure',
        () {
      // `(x) { var y = x; y = y + 1; return y; }` (after execution the
      // local `y` is 6 when called with 5).
      final r = makeResolver();
      const source = '(x) { var y = x; y = y + 1; return y; }';
      final result = r.resolve(parser.parse(source), testContext());
      final closure = result! as RuneClosure;
      expect(closure.call(const <Object?>[5]), 6);
    });

    test(
        'top-level AssignmentExpression (no scope) raises a clear '
        'diagnostic', () {
      // Outside a closure body there is no scope to write to and the
      // name is not in data: should surface as a BindingException.
      final r = makeResolver();
      const source = 'x = 5';
      final ctx = testContext(source: source);
      expect(
        () => r.resolve(parser.parse(source), ctx),
        throwsA(isA<BindingException>()),
      );
    });

    test('compound assignment operators are rejected', () {
      final r = makeResolver();
      const source = '(x) { var y = x; y += 1; return y; }';
      try {
        final result = r.resolve(parser.parse(source), testContext());
        (result! as RuneClosure).call(const <Object?>[1]);
        fail('expected ResolveException');
      } on ResolveException catch (e) {
        expect(e.message, contains('Unsupported assignment operator'));
      }
    });

    test('assignment with non-identifier LHS is rejected', () {
      // `a[0] = 1`: Phase B only supports SimpleIdentifier LHS.
      final r = makeResolver();
      const source = '(a) { a[0] = 1; return a; }';
      try {
        final result = r.resolve(parser.parse(source), testContext());
        (result! as RuneClosure).call(const <Object?>[
          [0],
        ]);
        fail('expected ResolveException');
      } on ResolveException catch (e) {
        expect(e.message, contains('Unsupported assignment target'));
      }
    });
  });
}

import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_data_context.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/parser/dart_parser.dart';
import 'package:rune/src/resolver/builtin_members.dart';
import 'package:rune/src/resolver/expression_resolver.dart';
import 'package:rune/src/resolver/identifier_resolver.dart';
import 'package:rune/src/resolver/invocation_resolver.dart';
import 'package:rune/src/resolver/literal_resolver.dart';
import 'package:rune/src/resolver/property_resolver.dart';

import '../_helpers/test_context.dart';

void main() {
  final parser = DartParser();

  // Build a minimal pipeline so we can parse real AST nodes and drive
  // `invokeBuiltinMethod` with a realistic `sourceNode` + `ctx`. The
  // `invokeBuiltinMethod` entry point only needs the expression resolver
  // to resolve its positional/named arguments — not to dispatch the
  // target itself. We still wire Property + Invocation because some
  // test cases will use e.g. `'x'.contains('a')` shaped argument ASTs.
  ({ExpressionResolver expr, PropertyResolver prop}) buildPipeline(
      {RuneDataContext? data,}) {
    final expr = ExpressionResolver(LiteralResolver(), IdentifierResolver());
    final inv = InvocationResolver(expr);
    final prop = PropertyResolver(expr);
    expr
      ..bind(inv)
      ..bindProperty(prop);
    return (expr: expr, prop: prop);
  }

  /// Parses `expression` — an expression whose outermost shape is a
  /// `MethodInvocation` with a SimpleIdentifier target (e.g.
  /// `'x'.contains('a')` parses as a PropertyAccess on the AdjacentStrings…
  /// no — actually for `'x'.contains('a')` the outer AST is a
  /// `MethodInvocation` whose target is a `StringLiteral`). Returns the
  /// MethodInvocation node.
  MethodInvocation parseMethod(String source) {
    final parsed = parser.parse(source);
    return parsed as MethodInvocation;
  }

  group('resolveBuiltinProperty — String', () {
    test("'hello'.length → 5", () {
      expect(resolveBuiltinProperty('hello', 'length'), (true, 5));
    });

    test("''.isEmpty → true", () {
      expect(resolveBuiltinProperty('', 'isEmpty'), (true, true));
    });

    test("'x'.isNotEmpty → true", () {
      expect(resolveBuiltinProperty('x', 'isNotEmpty'), (true, true));
    });
  });

  group('resolveBuiltinProperty — List', () {
    test('[1,2,3].length → 3', () {
      expect(resolveBuiltinProperty([1, 2, 3], 'length'), (true, 3));
    });

    test('[].isEmpty → true', () {
      expect(resolveBuiltinProperty(<Object?>[], 'isEmpty'), (true, true));
    });

    test('[1].isNotEmpty → true', () {
      expect(resolveBuiltinProperty([1], 'isNotEmpty'), (true, true));
    });

    test('[10,20].first → 10', () {
      expect(resolveBuiltinProperty([10, 20], 'first'), (true, 10));
    });

    test('[10,20].last → 20', () {
      expect(resolveBuiltinProperty([10, 20], 'last'), (true, 20));
    });
  });

  group('resolveBuiltinProperty — Map', () {
    test("{'a':1,'b':2}.length → 2", () {
      expect(
        resolveBuiltinProperty(<String, Object?>{'a': 1, 'b': 2}, 'length'),
        (true, 2),
      );
    });

    test('{}.isEmpty → true', () {
      expect(
        resolveBuiltinProperty(<String, Object?>{}, 'isEmpty'),
        (true, true),
      );
    });

    test('{}.isNotEmpty → false', () {
      expect(
        resolveBuiltinProperty(<String, Object?>{}, 'isNotEmpty'),
        (true, false),
      );
    });

    test("{'a':1}.keys → ['a']", () {
      final result =
          resolveBuiltinProperty(<String, Object?>{'a': 1}, 'keys');
      expect(result.$1, true);
      expect(result.$2, isA<List<Object?>>());
      expect(result.$2, ['a']);
    });

    test("{'a':1}.values → [1]", () {
      final result =
          resolveBuiltinProperty(<String, Object?>{'a': 1}, 'values');
      expect(result.$1, true);
      expect(result.$2, isA<List<Object?>>());
      expect(result.$2, [1]);
    });
  });

  group('resolveBuiltinProperty — misses', () {
    test('num has no .length → (false, null)', () {
      expect(resolveBuiltinProperty(42, 'length'), (false, null));
    });

    test("'x'.nope → (false, null)", () {
      expect(resolveBuiltinProperty('x', 'nope'), (false, null));
    });

    test('null with any property → (false, null)', () {
      expect(resolveBuiltinProperty(null, 'length'), (false, null));
    });
  });

  group('invokeBuiltinMethod — Object.toString', () {
    test('null.toString() → "null"', () {
      final node = parseMethod('toString()');
      final out = invokeBuiltinMethod(
        target: null,
        methodName: 'toString',
        positionalArgs: const <Object?>[],
        namedArgs: const <String, Object?>{},
        sourceNode: node,
        ctx: testContext(),
      );
      expect(out, 'null');
    });

    test('42.toString() → "42"', () {
      final node = parseMethod('x.toString()');
      final out = invokeBuiltinMethod(
        target: 42,
        methodName: 'toString',
        positionalArgs: const <Object?>[],
        namedArgs: const <String, Object?>{},
        sourceNode: node,
        ctx: testContext(),
      );
      expect(out, '42');
    });
  });

  group('invokeBuiltinMethod — String', () {
    test("'HELLO'.toLowerCase() → 'hello'", () {
      final node = parseMethod("'HELLO'.toLowerCase()");
      expect(
        invokeBuiltinMethod(
          target: 'HELLO',
          methodName: 'toLowerCase',
          positionalArgs: const <Object?>[],
          namedArgs: const <String, Object?>{},
          sourceNode: node,
          ctx: testContext(),
        ),
        'hello',
      );
    });

    test("'hello'.toUpperCase() → 'HELLO'", () {
      final node = parseMethod("'hello'.toUpperCase()");
      expect(
        invokeBuiltinMethod(
          target: 'hello',
          methodName: 'toUpperCase',
          positionalArgs: const <Object?>[],
          namedArgs: const <String, Object?>{},
          sourceNode: node,
          ctx: testContext(),
        ),
        'HELLO',
      );
    });

    test("'  x  '.trim() → 'x'", () {
      final node = parseMethod("'  x  '.trim()");
      expect(
        invokeBuiltinMethod(
          target: '  x  ',
          methodName: 'trim',
          positionalArgs: const <Object?>[],
          namedArgs: const <String, Object?>{},
          sourceNode: node,
          ctx: testContext(),
        ),
        'x',
      );
    });

    test("'banana'.contains('an') → true", () {
      final node = parseMethod("'banana'.contains('an')");
      expect(
        invokeBuiltinMethod(
          target: 'banana',
          methodName: 'contains',
          positionalArgs: const <Object?>['an'],
          namedArgs: const <String, Object?>{},
          sourceNode: node,
          ctx: testContext(),
        ),
        true,
      );
    });

    test("'banana'.startsWith('ba') → true", () {
      final node = parseMethod("'banana'.startsWith('ba')");
      expect(
        invokeBuiltinMethod(
          target: 'banana',
          methodName: 'startsWith',
          positionalArgs: const <Object?>['ba'],
          namedArgs: const <String, Object?>{},
          sourceNode: node,
          ctx: testContext(),
        ),
        true,
      );
    });

    test("'banana'.endsWith('na') → true", () {
      final node = parseMethod("'banana'.endsWith('na')");
      expect(
        invokeBuiltinMethod(
          target: 'banana',
          methodName: 'endsWith',
          positionalArgs: const <Object?>['na'],
          namedArgs: const <String, Object?>{},
          sourceNode: node,
          ctx: testContext(),
        ),
        true,
      );
    });

    test("'a,b,c'.split(',') → ['a','b','c']", () {
      final node = parseMethod("'a,b,c'.split(',')");
      expect(
        invokeBuiltinMethod(
          target: 'a,b,c',
          methodName: 'split',
          positionalArgs: const <Object?>[','],
          namedArgs: const <String, Object?>{},
          sourceNode: node,
          ctx: testContext(),
        ),
        ['a', 'b', 'c'],
      );
    });

    test("'banana'.substring(2) → 'nana'", () {
      final node = parseMethod("'banana'.substring(2)");
      expect(
        invokeBuiltinMethod(
          target: 'banana',
          methodName: 'substring',
          positionalArgs: const <Object?>[2],
          namedArgs: const <String, Object?>{},
          sourceNode: node,
          ctx: testContext(),
        ),
        'nana',
      );
    });

    test("'banana'.substring(2, 4) → 'na'", () {
      final node = parseMethod("'banana'.substring(2, 4)");
      expect(
        invokeBuiltinMethod(
          target: 'banana',
          methodName: 'substring',
          positionalArgs: const <Object?>[2, 4],
          namedArgs: const <String, Object?>{},
          sourceNode: node,
          ctx: testContext(),
        ),
        'na',
      );
    });

    test("'foo'.replaceAll('o', 'X') → 'fXX'", () {
      final node = parseMethod("'foo'.replaceAll('o', 'X')");
      expect(
        invokeBuiltinMethod(
          target: 'foo',
          methodName: 'replaceAll',
          positionalArgs: const <Object?>['o', 'X'],
          namedArgs: const <String, Object?>{},
          sourceNode: node,
          ctx: testContext(),
        ),
        'fXX',
      );
    });
  });

  group('invokeBuiltinMethod — List', () {
    test('[1,2,3].contains(2) → true', () {
      final node = parseMethod('x.contains(2)');
      expect(
        invokeBuiltinMethod(
          target: const [1, 2, 3],
          methodName: 'contains',
          positionalArgs: const <Object?>[2],
          namedArgs: const <String, Object?>{},
          sourceNode: node,
          ctx: testContext(),
        ),
        true,
      );
    });

    test('[1,2,3].indexOf(2) → 1', () {
      final node = parseMethod('x.indexOf(2)');
      expect(
        invokeBuiltinMethod(
          target: const [1, 2, 3],
          methodName: 'indexOf',
          positionalArgs: const <Object?>[2],
          namedArgs: const <String, Object?>{},
          sourceNode: node,
          ctx: testContext(),
        ),
        1,
      );
    });

    test("['a','b','c'].join('-') → 'a-b-c'", () {
      final node = parseMethod("x.join('-')");
      expect(
        invokeBuiltinMethod(
          target: const ['a', 'b', 'c'],
          methodName: 'join',
          positionalArgs: const <Object?>['-'],
          namedArgs: const <String, Object?>{},
          sourceNode: node,
          ctx: testContext(),
        ),
        'a-b-c',
      );
    });

    test("['a','b','c'].join() → 'abc'", () {
      final node = parseMethod('x.join()');
      expect(
        invokeBuiltinMethod(
          target: const ['a', 'b', 'c'],
          methodName: 'join',
          positionalArgs: const <Object?>[],
          namedArgs: const <String, Object?>{},
          sourceNode: node,
          ctx: testContext(),
        ),
        'abc',
      );
    });
  });

  group('invokeBuiltinMethod — Map', () {
    test("{'a':1}.containsKey('a') → true", () {
      final node = parseMethod("x.containsKey('a')");
      expect(
        invokeBuiltinMethod(
          target: const <String, Object?>{'a': 1},
          methodName: 'containsKey',
          positionalArgs: const <Object?>['a'],
          namedArgs: const <String, Object?>{},
          sourceNode: node,
          ctx: testContext(),
        ),
        true,
      );
    });

    test("{'a':1}.containsValue(1) → true", () {
      final node = parseMethod('x.containsValue(1)');
      expect(
        invokeBuiltinMethod(
          target: const <String, Object?>{'a': 1},
          methodName: 'containsValue',
          positionalArgs: const <Object?>[1],
          namedArgs: const <String, Object?>{},
          sourceNode: node,
          ctx: testContext(),
        ),
        true,
      );
    });
  });

  group('invokeBuiltinMethod — num', () {
    test('(-5).abs() → 5', () {
      final node = parseMethod('x.abs()');
      expect(
        invokeBuiltinMethod(
          target: -5,
          methodName: 'abs',
          positionalArgs: const <Object?>[],
          namedArgs: const <String, Object?>{},
          sourceNode: node,
          ctx: testContext(),
        ),
        5,
      );
    });

    test('3.7.round() → 4', () {
      final node = parseMethod('x.round()');
      expect(
        invokeBuiltinMethod(
          target: 3.7,
          methodName: 'round',
          positionalArgs: const <Object?>[],
          namedArgs: const <String, Object?>{},
          sourceNode: node,
          ctx: testContext(),
        ),
        4,
      );
    });

    test('3.7.floor() → 3', () {
      final node = parseMethod('x.floor()');
      expect(
        invokeBuiltinMethod(
          target: 3.7,
          methodName: 'floor',
          positionalArgs: const <Object?>[],
          namedArgs: const <String, Object?>{},
          sourceNode: node,
          ctx: testContext(),
        ),
        3,
      );
    });

    test('3.2.ceil() → 4', () {
      final node = parseMethod('x.ceil()');
      expect(
        invokeBuiltinMethod(
          target: 3.2,
          methodName: 'ceil',
          positionalArgs: const <Object?>[],
          namedArgs: const <String, Object?>{},
          sourceNode: node,
          ctx: testContext(),
        ),
        4,
      );
    });

    test('3.9.toInt() → 3', () {
      final node = parseMethod('x.toInt()');
      expect(
        invokeBuiltinMethod(
          target: 3.9,
          methodName: 'toInt',
          positionalArgs: const <Object?>[],
          namedArgs: const <String, Object?>{},
          sourceNode: node,
          ctx: testContext(),
        ),
        3,
      );
    });

    test('3.toDouble() → 3.0', () {
      final node = parseMethod('x.toDouble()');
      expect(
        invokeBuiltinMethod(
          target: 3,
          methodName: 'toDouble',
          positionalArgs: const <Object?>[],
          namedArgs: const <String, Object?>{},
          sourceNode: node,
          ctx: testContext(),
        ),
        3.0,
      );
    });
  });

  group('invokeBuiltinMethod — error paths', () {
    test("'x'.contains('a', 'b') → ResolveException (arity)", () {
      final node = parseMethod("'x'.contains('a', 'b')");
      expect(
        () => invokeBuiltinMethod(
          target: 'x',
          methodName: 'contains',
          positionalArgs: const <Object?>['a', 'b'],
          namedArgs: const <String, Object?>{},
          sourceNode: node,
          ctx: testContext(),
        ),
        throwsA(
          isA<ResolveException>()
              .having((e) => e.message, 'message', contains('positional')),
        ),
      );
    });

    test("'x'.contains(123) → ResolveException (type mismatch)", () {
      final node = parseMethod("'x'.contains(123)");
      expect(
        () => invokeBuiltinMethod(
          target: 'x',
          methodName: 'contains',
          positionalArgs: const <Object?>[123],
          namedArgs: const <String, Object?>{},
          sourceNode: node,
          ctx: testContext(),
        ),
        throwsA(
          isA<ResolveException>()
              .having((e) => e.message, 'message', contains('String')),
        ),
      );
    });

    test("'x'.contains(needle: 'a') → ResolveException (named args)", () {
      final node = parseMethod("'x'.contains('a')");
      expect(
        () => invokeBuiltinMethod(
          target: 'x',
          methodName: 'contains',
          positionalArgs: const <Object?>[],
          namedArgs: const <String, Object?>{'needle': 'a'},
          sourceNode: node,
          ctx: testContext(),
        ),
        throwsA(
          isA<ResolveException>()
              .having((e) => e.message, 'message', contains('named')),
        ),
      );
    });

    test("'x'.banana() → ResolveException (unknown method)", () {
      final node = parseMethod("'x'.banana()");
      expect(
        () => invokeBuiltinMethod(
          target: 'x',
          methodName: 'banana',
          positionalArgs: const <Object?>[],
          namedArgs: const <String, Object?>{},
          sourceNode: node,
          ctx: testContext(),
        ),
        throwsA(
          isA<ResolveException>()
              .having((e) => e.message, 'message', contains('banana'))
              .having((e) => e.message, 'message', contains('String')),
        ),
      );
    });

    test('substring with 3 args → ResolveException (arity)', () {
      final node = parseMethod("'abcdef'.substring(1, 2, 3)");
      expect(
        () => invokeBuiltinMethod(
          target: 'abcdef',
          methodName: 'substring',
          positionalArgs: const <Object?>[1, 2, 3],
          namedArgs: const <String, Object?>{},
          sourceNode: node,
          ctx: testContext(),
        ),
        throwsA(isA<ResolveException>()),
      );
    });

    test('error carries a SourceSpan location', () {
      // Drive parseMethod with a known source so the node's offset maps
      // into a meaningful SourceSpan via `ctx.source`.
      const src = "'x'.banana()";
      final node = parseMethod(src);
      final ctx = testContext(source: src);
      try {
        invokeBuiltinMethod(
          target: 'x',
          methodName: 'banana',
          positionalArgs: const <Object?>[],
          namedArgs: const <String, Object?>{},
          sourceNode: node,
          ctx: ctx,
        );
        fail('expected ResolveException');
      } on ResolveException catch (e) {
        expect(e.location, isNotNull);
        expect(e.location!.line, 1);
        expect(e.location!.excerpt, "'x'.banana()");
      }
    });
  });

  // Sanity: the pipeline builder referenced above is constructed so this
  // file's imports stay honest. The pipeline is used transitively by the
  // parser-driven helpers.
  test('pipeline construction is sound', () {
    final p = buildPipeline();
    expect(p.expr, isNotNull);
    expect(p.prop, isNotNull);
  });
}

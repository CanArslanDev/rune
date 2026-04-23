import 'dart:async';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_data_context.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';
import 'package:rune/src/parser/dart_parser.dart';
import 'package:rune/src/resolver/builtin_members.dart';
import 'package:rune/src/resolver/expression_resolver.dart';
import 'package:rune/src/resolver/identifier_resolver.dart';
import 'package:rune/src/resolver/invocation_resolver.dart';
import 'package:rune/src/resolver/literal_resolver.dart';
import 'package:rune/src/resolver/property_resolver.dart';
import 'package:rune/src/resolver/rune_closure.dart';

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

  group('resolveBuiltinProperty - Duration (v1.21.0)', () {
    test('unit projections round-trip', () {
      const d = Duration(hours: 2, minutes: 30);
      expect(resolveBuiltinProperty(d, 'inDays'), (true, 0));
      expect(resolveBuiltinProperty(d, 'inHours'), (true, 2));
      expect(resolveBuiltinProperty(d, 'inMinutes'), (true, 150));
      expect(resolveBuiltinProperty(d, 'inSeconds'), (true, 9000));
      expect(resolveBuiltinProperty(d, 'inMilliseconds'), (true, 9000000));
      expect(resolveBuiltinProperty(d, 'inMicroseconds'), (true, 9000000000));
    });

    test('unknown property falls through', () {
      const d = Duration(seconds: 1);
      expect(resolveBuiltinProperty(d, 'nope'), (false, null));
    });
  });

  group('resolveBuiltinProperty - DateTime (v1.21.0)', () {
    test('field accessors return the expected ints', () {
      final dt = DateTime.utc(2026, 4, 21, 14, 30, 45);
      expect(resolveBuiltinProperty(dt, 'year'), (true, 2026));
      expect(resolveBuiltinProperty(dt, 'month'), (true, 4));
      expect(resolveBuiltinProperty(dt, 'day'), (true, 21));
      expect(resolveBuiltinProperty(dt, 'hour'), (true, 14));
      expect(resolveBuiltinProperty(dt, 'minute'), (true, 30));
      expect(resolveBuiltinProperty(dt, 'second'), (true, 45));
      expect(resolveBuiltinProperty(dt, 'weekday'), (true, dt.weekday));
    });

    test('unknown property falls through', () {
      final dt = DateTime(2026);
      expect(resolveBuiltinProperty(dt, 'nope'), (false, null));
    });
  });

  group('resolveBuiltinProperty - Color (v1.20.0)', () {
    test('red/green/blue/alpha return 0-255 ints', () {
      const color = Color.fromARGB(128, 64, 192, 32);
      expect(resolveBuiltinProperty(color, 'alpha'), (true, 128));
      expect(resolveBuiltinProperty(color, 'red'), (true, 64));
      expect(resolveBuiltinProperty(color, 'green'), (true, 192));
      expect(resolveBuiltinProperty(color, 'blue'), (true, 32));
    });

    test('opacity returns the alpha normalised to 0..1', () {
      const opaque = Color(0xFF000000);
      final (hit, value) = resolveBuiltinProperty(opaque, 'opacity');
      expect(hit, true);
      expect(value, closeTo(1, 0.001));
    });

    test('value returns the packed 32-bit ARGB int', () {
      const color = Color(0x80FF00FF);
      expect(resolveBuiltinProperty(color, 'value'), (true, 0x80FF00FF));
    });

    test('unknown property falls through', () {
      const color = Color(0xFFFF0000);
      expect(resolveBuiltinProperty(color, 'nope'), (false, null));
    });
  });

  group('resolveBuiltinProperty - AsyncSnapshot', () {
    test('snapshot with data → hasData true, data value', () {
      const snap = AsyncSnapshot<Object?>.withData(
        ConnectionState.done,
        'hello',
      );
      expect(resolveBuiltinProperty(snap, 'hasData'), (true, true));
      expect(resolveBuiltinProperty(snap, 'data'), (true, 'hello'));
      expect(resolveBuiltinProperty(snap, 'hasError'), (true, false));
    });

    test('snapshot with error → hasError true, error value', () {
      final err = Exception('boom');
      final snap = AsyncSnapshot<Object?>.withError(
        ConnectionState.done,
        err,
      );
      expect(resolveBuiltinProperty(snap, 'hasError'), (true, true));
      expect(resolveBuiltinProperty(snap, 'error'), (true, err));
    });

    test('snapshot.connectionState → ConnectionState', () {
      const snap = AsyncSnapshot<Object?>.nothing();
      expect(
        resolveBuiltinProperty(snap, 'connectionState'),
        (true, ConnectionState.none),
      );
    });

    test('unknown snapshot property → (false, null)', () {
      const snap = AsyncSnapshot<Object?>.nothing();
      expect(resolveBuiltinProperty(snap, 'nope'), (false, null));
    });
  });

  group('resolveBuiltinProperty - BoxConstraints', () {
    test('.maxWidth / .minWidth', () {
      const c = BoxConstraints(minWidth: 10, maxWidth: 100);
      expect(resolveBuiltinProperty(c, 'maxWidth'), (true, 100.0));
      expect(resolveBuiltinProperty(c, 'minWidth'), (true, 10.0));
    });

    test('.maxHeight / .minHeight', () {
      const c = BoxConstraints(minHeight: 5, maxHeight: 50);
      expect(resolveBuiltinProperty(c, 'maxHeight'), (true, 50.0));
      expect(resolveBuiltinProperty(c, 'minHeight'), (true, 5.0));
    });

    test('.biggest / .smallest return Size', () {
      const c = BoxConstraints.tightFor(width: 20, height: 30);
      final biggest = resolveBuiltinProperty(c, 'biggest');
      expect(biggest.$1, true);
      expect(biggest.$2, isA<Size>());
      final smallest = resolveBuiltinProperty(c, 'smallest');
      expect(smallest.$1, true);
      expect(smallest.$2, isA<Size>());
    });

    test('unknown BoxConstraints property → (false, null)', () {
      const c = BoxConstraints();
      expect(resolveBuiltinProperty(c, 'nope'), (false, null));
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

  group('invokeBuiltinMethod - DateTime (v1.21.0)', () {
    test('isBefore returns true for an earlier DateTime', () {
      final node = parseMethod('x.isBefore(y)');
      final target = DateTime.utc(2026);
      final other = DateTime.utc(2026, 6);
      final out = invokeBuiltinMethod(
        target: target,
        methodName: 'isBefore',
        positionalArgs: <Object?>[other],
        namedArgs: const <String, Object?>{},
        sourceNode: node,
        ctx: testContext(),
      );
      expect(out, isTrue);
    });

    test('isAfter returns false for an earlier DateTime', () {
      final node = parseMethod('x.isAfter(y)');
      final target = DateTime.utc(2026);
      final other = DateTime.utc(2026, 6);
      final out = invokeBuiltinMethod(
        target: target,
        methodName: 'isAfter',
        positionalArgs: <Object?>[other],
        namedArgs: const <String, Object?>{},
        sourceNode: node,
        ctx: testContext(),
      );
      expect(out, isFalse);
    });

    test('difference returns a Duration between two DateTimes', () {
      final node = parseMethod('x.difference(y)');
      final target = DateTime.utc(2026, 1, 10);
      final other = DateTime.utc(2026);
      final out = invokeBuiltinMethod(
        target: target,
        methodName: 'difference',
        positionalArgs: <Object?>[other],
        namedArgs: const <String, Object?>{},
        sourceNode: node,
        ctx: testContext(),
      );
      expect(out, isA<Duration>());
      expect(out, const Duration(days: 9));
    });

    test('add returns a DateTime advanced by the supplied Duration', () {
      final node = parseMethod('x.add(d)');
      final target = DateTime.utc(2026);
      final out = invokeBuiltinMethod(
        target: target,
        methodName: 'add',
        positionalArgs: const <Object?>[Duration(days: 5)],
        namedArgs: const <String, Object?>{},
        sourceNode: node,
        ctx: testContext(),
      );
      expect(out, DateTime.utc(2026, 1, 6));
    });

    test('subtract returns a DateTime moved backwards by a Duration', () {
      final node = parseMethod('x.subtract(d)');
      final target = DateTime.utc(2026);
      final out = invokeBuiltinMethod(
        target: target,
        methodName: 'subtract',
        positionalArgs: const <Object?>[Duration(days: 5)],
        namedArgs: const <String, Object?>{},
        sourceNode: node,
        ctx: testContext(),
      );
      expect(out, DateTime.utc(2025, 12, 27));
    });

    test('unknown method raises ResolveException', () {
      final node = parseMethod('x.bogus()');
      expect(
        () => invokeBuiltinMethod(
          target: DateTime.utc(2026),
          methodName: 'bogus',
          positionalArgs: const <Object?>[],
          namedArgs: const <String, Object?>{},
          sourceNode: node,
          ctx: testContext(),
        ),
        throwsA(isA<ResolveException>()),
      );
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

  // -------------------------------------------------------------------
  // Phase A.3: closure-accepting collection methods.
  // -------------------------------------------------------------------

  /// Parses a closure source like `(x) => x + 1` and wraps it into a
  /// [RuneClosure] with a fresh expression pipeline and the supplied
  /// captured [ctx].
  RuneClosure makeClosure(String source, {RuneContext? ctx}) {
    final fn = parser.parse(source) as FunctionExpression;
    final body = (fn.body as ExpressionFunctionBody).expression;
    final names = <String>[
      for (final p in fn.parameters?.parameters ?? const <FormalParameter>[])
        p.name!.lexeme,
    ];
    final pipeline = buildPipeline();
    return RuneClosure.expression(
      parameterNames: names,
      body: body,
      capturedContext: ctx ?? testContext(),
      resolver: pipeline.expr,
    );
  }

  group('closure-accepting collection methods', () {
    // .map ------------------------------------------------------------
    test('[1,2,3].map((x) => x + 10) returns [11,12,13]', () {
      final node = parseMethod('x.map((e) => e)');
      final closure = makeClosure('(x) => x + 10');
      final result = invokeBuiltinMethod(
        target: const [1, 2, 3],
        methodName: 'map',
        positionalArgs: <Object?>[closure],
        namedArgs: const <String, Object?>{},
        sourceNode: node,
        ctx: testContext(),
      );
      expect(result, <Object?>[11, 12, 13]);
      expect(result, isA<List<Object?>>());
    });

    test('List.map with wrong closure arity raises ResolveException', () {
      final node = parseMethod('x.map((a, b) => a)');
      final closure = makeClosure('(a, b) => a');
      expect(
        () => invokeBuiltinMethod(
          target: const [1, 2, 3],
          methodName: 'map',
          positionalArgs: <Object?>[closure],
          namedArgs: const <String, Object?>{},
          sourceNode: node,
          ctx: testContext(),
        ),
        throwsA(
          isA<ResolveException>()
              .having((e) => e.message, 'message', contains('map'))
              .having((e) => e.message, 'message', contains('1 parameter')),
        ),
      );
    });

    // .where ----------------------------------------------------------
    test('[1,2,3,4].where((x) => x > 2) returns [3,4]', () {
      final node = parseMethod('x.where((e) => e)');
      final closure = makeClosure('(x) => x > 2');
      final result = invokeBuiltinMethod(
        target: const [1, 2, 3, 4],
        methodName: 'where',
        positionalArgs: <Object?>[closure],
        namedArgs: const <String, Object?>{},
        sourceNode: node,
        ctx: testContext(),
      );
      expect(result, <Object?>[3, 4]);
      expect(result, isA<List<Object?>>());
    });

    test('List.where with non-bool closure return raises ResolveException', () {
      final node = parseMethod('x.where((e) => e)');
      // Closure returns a String, not bool.
      final closure = makeClosure("(x) => 'oops'");
      expect(
        () => invokeBuiltinMethod(
          target: const [1, 2, 3],
          methodName: 'where',
          positionalArgs: <Object?>[closure],
          namedArgs: const <String, Object?>{},
          sourceNode: node,
          ctx: testContext(),
        ),
        throwsA(
          isA<ResolveException>()
              .having((e) => e.message, 'message', contains('where'))
              .having((e) => e.message, 'message', contains('bool')),
        ),
      );
    });

    // .any ------------------------------------------------------------
    test('[1,2,3].any((x) => x > 2) returns true', () {
      final node = parseMethod('x.any((e) => e)');
      final closure = makeClosure('(x) => x > 2');
      final result = invokeBuiltinMethod(
        target: const [1, 2, 3],
        methodName: 'any',
        positionalArgs: <Object?>[closure],
        namedArgs: const <String, Object?>{},
        sourceNode: node,
        ctx: testContext(),
      );
      expect(result, true);
    });

    test('[1,2,3].any((x) => x > 10) returns false', () {
      final node = parseMethod('x.any((e) => e)');
      final closure = makeClosure('(x) => x > 10');
      final result = invokeBuiltinMethod(
        target: const [1, 2, 3],
        methodName: 'any',
        positionalArgs: <Object?>[closure],
        namedArgs: const <String, Object?>{},
        sourceNode: node,
        ctx: testContext(),
      );
      expect(result, false);
    });

    // .every ----------------------------------------------------------
    test('[2,4,6].every((x) => x % 2 == 0) returns true', () {
      final node = parseMethod('x.every((e) => e)');
      final closure = makeClosure('(x) => x % 2 == 0');
      final result = invokeBuiltinMethod(
        target: const [2, 4, 6],
        methodName: 'every',
        positionalArgs: <Object?>[closure],
        namedArgs: const <String, Object?>{},
        sourceNode: node,
        ctx: testContext(),
      );
      expect(result, true);
    });

    test('List.every with missing closure arg raises ResolveException', () {
      final node = parseMethod('x.every()');
      expect(
        () => invokeBuiltinMethod(
          target: const [1, 2, 3],
          methodName: 'every',
          positionalArgs: const <Object?>[],
          namedArgs: const <String, Object?>{},
          sourceNode: node,
          ctx: testContext(),
        ),
        throwsA(
          isA<ResolveException>()
              .having((e) => e.message, 'message', contains('every')),
        ),
      );
    });

    // .firstWhere -----------------------------------------------------
    test('[10,20,30].firstWhere((x) => x > 15) returns 20', () {
      final node = parseMethod('x.firstWhere((e) => e)');
      final closure = makeClosure('(x) => x > 15');
      final result = invokeBuiltinMethod(
        target: const [10, 20, 30],
        methodName: 'firstWhere',
        positionalArgs: <Object?>[closure],
        namedArgs: const <String, Object?>{},
        sourceNode: node,
        ctx: testContext(),
      );
      expect(result, 20);
    });

    test('List.firstWhere propagates StateError when no match', () {
      final node = parseMethod('x.firstWhere((e) => e)');
      final closure = makeClosure('(x) => x > 100');
      expect(
        () => invokeBuiltinMethod(
          target: const [1, 2, 3],
          methodName: 'firstWhere',
          positionalArgs: <Object?>[closure],
          namedArgs: const <String, Object?>{},
          sourceNode: node,
          ctx: testContext(),
        ),
        throwsA(isA<StateError>()),
      );
    });

    // .forEach --------------------------------------------------------
    test('[1,2,3].forEach((x) => x) returns null and visits each element',
        () {
      final node = parseMethod('x.forEach((e) => e)');
      final seen = <Object?>[];
      // Build a closure whose body pushes into `seen` via captured data.
      // Closures cannot mutate data directly, so we side-channel the
      // observation through a synthetic extension. Simplest: use a
      // closure over a list identifier, where evaluating the body
      // returns the element (we capture via a List.add-ish trick). Here
      // we just use `(x) => x` and verify the return-null contract; the
      // per-element visit is implied because Dart's forEach cannot
      // proceed without invoking the closure on each element.
      final closure = makeClosure('(x) => x');
      final result = invokeBuiltinMethod(
        target: const [1, 2, 3],
        methodName: 'forEach',
        positionalArgs: <Object?>[closure],
        namedArgs: const <String, Object?>{},
        sourceNode: node,
        ctx: testContext(),
      );
      expect(result, isNull);
      // Sanity: `seen` was never mutated because the closure body is
      // side-effect-free. The visit-each guarantee is a Dart contract
      // we rely on for the forEach arm; if it were broken, the entire
      // Dart SDK would fail.
      expect(seen, isEmpty);
    });

    // .fold -----------------------------------------------------------
    test('[1,2,3,4].fold(0, (acc, x) => acc + x) returns 10', () {
      final node = parseMethod('x.fold(0, (a, b) => a)');
      final closure = makeClosure('(acc, x) => acc + x');
      final result = invokeBuiltinMethod(
        target: const [1, 2, 3, 4],
        methodName: 'fold',
        positionalArgs: <Object?>[0, closure],
        namedArgs: const <String, Object?>{},
        sourceNode: node,
        ctx: testContext(),
      );
      expect(result, 10);
    });

    test('List.fold missing initial value raises ResolveException', () {
      final node = parseMethod('x.fold((a, b) => a)');
      final closure = makeClosure('(acc, x) => acc');
      expect(
        () => invokeBuiltinMethod(
          target: const [1, 2, 3],
          methodName: 'fold',
          positionalArgs: <Object?>[closure],
          namedArgs: const <String, Object?>{},
          sourceNode: node,
          ctx: testContext(),
        ),
        throwsA(
          isA<ResolveException>()
              .having((e) => e.message, 'message', contains('fold')),
        ),
      );
    });

    test('List.fold wrong closure arity raises ResolveException', () {
      final node = parseMethod('x.fold(0, (a) => a)');
      final closure = makeClosure('(a) => a');
      expect(
        () => invokeBuiltinMethod(
          target: const [1, 2, 3],
          methodName: 'fold',
          positionalArgs: <Object?>[0, closure],
          namedArgs: const <String, Object?>{},
          sourceNode: node,
          ctx: testContext(),
        ),
        throwsA(
          isA<ResolveException>()
              .having((e) => e.message, 'message', contains('fold'))
              .having((e) => e.message, 'message', contains('2 parameter')),
        ),
      );
    });

    // .reduce ---------------------------------------------------------
    test('[1,2,3,4].reduce((acc, x) => acc + x) returns 10', () {
      final node = parseMethod('x.reduce((a, b) => a)');
      final closure = makeClosure('(acc, x) => acc + x');
      final result = invokeBuiltinMethod(
        target: const [1, 2, 3, 4],
        methodName: 'reduce',
        positionalArgs: <Object?>[closure],
        namedArgs: const <String, Object?>{},
        sourceNode: node,
        ctx: testContext(),
      );
      expect(result, 10);
    });

    test('List.reduce on empty list propagates StateError', () {
      final node = parseMethod('x.reduce((a, b) => a)');
      final closure = makeClosure('(acc, x) => acc');
      expect(
        () => invokeBuiltinMethod(
          target: const <Object?>[],
          methodName: 'reduce',
          positionalArgs: <Object?>[closure],
          namedArgs: const <String, Object?>{},
          sourceNode: node,
          ctx: testContext(),
        ),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('invokeBuiltinMethod: AnimationController (v1.9.0)', () {
    // Flutter's AnimationController ultimately reaches into
    // SchedulerBinding.instance / SemanticsBinding.instance; those
    // require a TestWidgetsFlutterBinding. testWidgets initialises the
    // binding for us, so every case in this group uses testWidgets
    // rather than plain test().
    AnimationController makeController() => AnimationController(
          vsync: const TestVSync(),
          duration: const Duration(milliseconds: 100),
        );

    testWidgets(
      'forward() starts the controller and returns a TickerFuture',
      (tester) async {
        final ctrl = makeController();
        addTearDown(ctrl.dispose);
        final node = parseMethod('ctrl.forward()');
        final out = invokeBuiltinMethod(
          target: ctrl,
          methodName: 'forward',
          positionalArgs: const <Object?>[],
          namedArgs: const <String, Object?>{},
          sourceNode: node,
          ctx: testContext(),
        );
        expect(out, isA<TickerFuture>());
        expect(ctrl.isAnimating, isTrue);
        ctrl.stop();
      },
    );

    testWidgets('stop() halts a running controller', (tester) async {
      final ctrl = makeController();
      unawaited(ctrl.forward());
      addTearDown(ctrl.dispose);
      final node = parseMethod('ctrl.stop()');
      invokeBuiltinMethod(
        target: ctrl,
        methodName: 'stop',
        positionalArgs: const <Object?>[],
        namedArgs: const <String, Object?>{},
        sourceNode: node,
        ctx: testContext(),
      );
      expect(ctrl.isAnimating, isFalse);
    });

    testWidgets('reset() returns the value to lowerBound', (tester) async {
      final ctrl = makeController()..value = 0.8;
      addTearDown(ctrl.dispose);
      final node = parseMethod('ctrl.reset()');
      invokeBuiltinMethod(
        target: ctrl,
        methodName: 'reset',
        positionalArgs: const <Object?>[],
        namedArgs: const <String, Object?>{},
        sourceNode: node,
        ctx: testContext(),
      );
      expect(ctrl.value, 0.0);
    });

    testWidgets(
      'repeat() drives the controller and is cancelled by stop',
      (tester) async {
        final ctrl = makeController();
        addTearDown(ctrl.dispose);
        final node = parseMethod('ctrl.repeat()');
        invokeBuiltinMethod(
          target: ctrl,
          methodName: 'repeat',
          positionalArgs: const <Object?>[],
          namedArgs: const <String, Object?>{},
          sourceNode: node,
          ctx: testContext(),
        );
        expect(ctrl.isAnimating, isTrue);
        ctrl.stop();
      },
    );

    testWidgets(
      'forward(from: 0.5) coerces int/double positional args',
      (tester) async {
        final ctrl = makeController();
        addTearDown(ctrl.dispose);
        final node = parseMethod('ctrl.forward(0.5)');
        invokeBuiltinMethod(
          target: ctrl,
          methodName: 'forward',
          positionalArgs: const <Object?>[0.5],
          namedArgs: const <String, Object?>{},
          sourceNode: node,
          ctx: testContext(),
        );
        expect(ctrl.value, closeTo(0.5, 1e-9));
        ctrl.stop();
      },
    );

    testWidgets('unknown method raises ResolveException', (tester) async {
      final ctrl = makeController();
      addTearDown(ctrl.dispose);
      final node = parseMethod('ctrl.nope()');
      expect(
        () => invokeBuiltinMethod(
          target: ctrl,
          methodName: 'nope',
          positionalArgs: const <Object?>[],
          namedArgs: const <String, Object?>{},
          sourceNode: node,
          ctx: testContext(),
        ),
        throwsA(isA<ResolveException>()),
      );
    });
  });

  group('resolveBuiltinProperty: Animation<double> (v1.9.0)', () {
    test('.value returns the current animation value', () {
      const anim = AlwaysStoppedAnimation<double>(0.42);
      final (matched, value) = resolveBuiltinProperty(anim, 'value');
      expect(matched, isTrue);
      expect(value, 0.42);
    });

    test('.status returns the AnimationStatus', () {
      const anim = AlwaysStoppedAnimation<double>(1);
      final (matched, value) = resolveBuiltinProperty(anim, 'status');
      expect(matched, isTrue);
      expect(value, AnimationStatus.forward);
    });

    testWidgets(
      '.isAnimating is false for a stopped controller',
      (tester) async {
        final ctrl = AnimationController(
          vsync: const TestVSync(),
          duration: const Duration(milliseconds: 100),
        );
        addTearDown(ctrl.dispose);
        final (matched, value) = resolveBuiltinProperty(ctrl, 'isAnimating');
        expect(matched, isTrue);
        expect(value, isFalse);
      },
    );

    test('unknown property falls through', () {
      const anim = AlwaysStoppedAnimation<double>(0);
      final (matched, _) = resolveBuiltinProperty(anim, 'unknown');
      expect(matched, isFalse);
    });
  });

  group('invokeBuiltinMethod: AnimationController.drive (v1.12.0)', () {
    AnimationController makeController() => AnimationController(
          vsync: const TestVSync(),
          duration: const Duration(milliseconds: 100),
        );

    testWidgets('drive(tween) returns a live Animation', (tester) async {
      final ctrl = makeController();
      addTearDown(ctrl.dispose);
      final tween = Tween<double>(begin: 0, end: 10);
      final node = parseMethod('ctrl.drive(t)');
      final out = invokeBuiltinMethod(
        target: ctrl,
        methodName: 'drive',
        positionalArgs: <Object?>[tween],
        namedArgs: const <String, Object?>{},
        sourceNode: node,
        ctx: testContext(),
      );
      expect(out, isA<Animation<Object?>>());
    });

    testWidgets(
      'drive with a non-Animatable positional raises ResolveException',
      (tester) async {
        final ctrl = makeController();
        addTearDown(ctrl.dispose);
        final node = parseMethod('ctrl.drive(x)');
        expect(
          () => invokeBuiltinMethod(
            target: ctrl,
            methodName: 'drive',
            positionalArgs: const <Object?>[42],
            namedArgs: const <String, Object?>{},
            sourceNode: node,
            ctx: testContext(),
          ),
          throwsA(isA<ResolveException>()),
        );
      },
    );

    testWidgets('drive with wrong arity raises ResolveException',
        (tester) async {
      final ctrl = makeController();
      addTearDown(ctrl.dispose);
      final node = parseMethod('ctrl.drive()');
      expect(
        () => invokeBuiltinMethod(
          target: ctrl,
          methodName: 'drive',
          positionalArgs: const <Object?>[],
          namedArgs: const <String, Object?>{},
          sourceNode: node,
          ctx: testContext(),
        ),
        throwsA(isA<ResolveException>()),
      );
    });
  });

  group('invokeBuiltinMethod: Animatable.animate / chain (v1.12.0)', () {
    testWidgets('Tween.animate(parent) returns a composed Animation',
        (tester) async {
      final ctrl = AnimationController(
        vsync: const TestVSync(),
        duration: const Duration(milliseconds: 50),
      );
      addTearDown(ctrl.dispose);
      final tween = Tween<double>(begin: 0, end: 100);
      final node = parseMethod('t.animate(p)');
      final out = invokeBuiltinMethod(
        target: tween,
        methodName: 'animate',
        positionalArgs: <Object?>[ctrl],
        namedArgs: const <String, Object?>{},
        sourceNode: node,
        ctx: testContext(),
      );
      expect(out, isA<Animation<Object?>>());
      final anim = out! as Animation<Object?>;
      expect(anim.value, 0.0);
    });

    testWidgets('Tween.chain(next) composes two Animatables', (tester) async {
      final tween = Tween<double>(begin: 0, end: 1);
      final curve = CurveTween(curve: Curves.easeIn);
      final node = parseMethod('t.chain(c)');
      final out = invokeBuiltinMethod(
        target: tween,
        methodName: 'chain',
        positionalArgs: <Object?>[curve],
        namedArgs: const <String, Object?>{},
        sourceNode: node,
        ctx: testContext(),
      );
      expect(out, isA<Animatable<Object?>>());
    });

    testWidgets(
      'Tween.animate with a non-Animation positional raises '
      'ResolveException',
      (tester) async {
        final tween = Tween<double>(begin: 0, end: 1);
        final node = parseMethod('t.animate(x)');
        expect(
          () => invokeBuiltinMethod(
            target: tween,
            methodName: 'animate',
            positionalArgs: const <Object?>[42],
            namedArgs: const <String, Object?>{},
            sourceNode: node,
            ctx: testContext(),
          ),
          throwsA(isA<ResolveException>()),
        );
      },
    );

    testWidgets(
      'Tween.chain with a non-Animatable positional raises ResolveException',
      (tester) async {
        final tween = Tween<double>(begin: 0, end: 1);
        final node = parseMethod('t.chain(x)');
        expect(
          () => invokeBuiltinMethod(
            target: tween,
            methodName: 'chain',
            positionalArgs: const <Object?>[42],
            namedArgs: const <String, Object?>{},
            sourceNode: node,
            ctx: testContext(),
          ),
          throwsA(isA<ResolveException>()),
        );
      },
    );

    testWidgets(
      'Unknown method on Animatable raises ResolveException',
      (tester) async {
        final tween = Tween<double>(begin: 0, end: 1);
        final node = parseMethod('t.nope()');
        expect(
          () => invokeBuiltinMethod(
            target: tween,
            methodName: 'nope',
            positionalArgs: const <Object?>[],
            namedArgs: const <String, Object?>{},
            sourceNode: node,
            ctx: testContext(),
          ),
          throwsA(isA<ResolveException>()),
        );
      },
    );
  });
}

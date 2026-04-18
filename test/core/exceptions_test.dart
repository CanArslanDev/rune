import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/source_span.dart';

void main() {
  group('RuneException hierarchy', () {
    test('ParseException carries source and message', () {
      const e = ParseException('Bad(', 'Unexpected token');
      expect(e.source, 'Bad(');
      expect(e.message, 'Unexpected token');
      expect(e, isA<RuneException>());
      expect(e.toString(), contains('ParseException'));
      expect(e.toString(), contains('Bad('));
      expect(e.toString(), contains('Unexpected token'));
    });

    test('ResolveException carries source and message', () {
      const e = ResolveException('foo', 'not supported');
      expect(e.source, 'foo');
      expect(e.message, 'not supported');
      expect(e, isA<RuneException>());
    });

    test(
      'UnregisteredBuilderException exposes typeName and carries source',
      () {
        const e = UnregisteredBuilderException('FooBar()', 'FooBar');
        expect(e.source, 'FooBar()');
        expect(e.typeName, 'FooBar');
        expect(e.message, contains('FooBar'));
        expect(e, isA<RuneException>());
        expect(e.toString(), contains('FooBar'));
      },
    );

    test('ArgumentException carries source and message', () {
      const e = ArgumentException('Text()', 'missing "data"');
      expect(e.source, 'Text()');
      expect(e.message, 'missing "data"');
      expect(e, isA<RuneException>());
    });

    test('BindingException carries source and message', () {
      const e = BindingException('userName', 'not in data');
      expect(e.source, 'userName');
      expect(e.message, 'not in data');
      expect(e, isA<RuneException>());
    });

    test('pattern match is exhaustive over sealed class', () {
      const RuneException e = ParseException('x', 'y');
      final label = switch (e) {
        ParseException() => 'parse',
        ResolveException() => 'resolve',
        UnregisteredBuilderException() => 'unregistered',
        ArgumentException() => 'argument',
        BindingException() => 'binding',
      };
      expect(label, 'parse');
    });
  });

  group('RuneException.location field', () {
    const span = SourceSpan(
      offset: 5,
      length: 4,
      line: 1,
      column: 6,
      excerpt: 'hello Text()',
    );

    test('ParseException.location defaults to null', () {
      const e = ParseException('Bad(', 'Unexpected token');
      expect(e.location, isNull);
    });

    test('ParseException.location round-trips when provided', () {
      const e = ParseException('Bad(', 'Unexpected token', location: span);
      expect(e.location, same(span));
    });

    test('ResolveException.location defaults to null', () {
      const e = ResolveException('foo', 'not supported');
      expect(e.location, isNull);
    });

    test('ResolveException.location round-trips when provided', () {
      const e = ResolveException('foo', 'not supported', location: span);
      expect(e.location, same(span));
    });

    test('UnregisteredBuilderException.location defaults to null', () {
      const e = UnregisteredBuilderException('FooBar()', 'FooBar');
      expect(e.location, isNull);
    });

    test('UnregisteredBuilderException.location round-trips when provided',
        () {
      const e =
          UnregisteredBuilderException('FooBar()', 'FooBar', location: span);
      expect(e.location, same(span));
    });

    test('ArgumentException.location defaults to null', () {
      const e = ArgumentException('Text()', 'missing "data"');
      expect(e.location, isNull);
    });

    test('ArgumentException.location round-trips when provided', () {
      const e = ArgumentException('Text()', 'missing "data"', location: span);
      expect(e.location, same(span));
    });

    test('BindingException.location defaults to null', () {
      const e = BindingException('userName', 'not in data');
      expect(e.location, isNull);
    });

    test('BindingException.location round-trips when provided', () {
      const e = BindingException('userName', 'not in data', location: span);
      expect(e.location, same(span));
    });

    test('location access does not alter existing source/message', () {
      const e = ResolveException('foo', 'bar', location: span);
      expect(e.source, 'foo');
      expect(e.message, 'bar');
      expect(e.location, same(span));
    });
  });
}

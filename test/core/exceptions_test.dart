import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/core/exceptions.dart';

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

    test('ResolveException is a RuneException', () {
      const e = ResolveException('foo', 'not supported');
      expect(e, isA<RuneException>());
    });

    test('UnregisteredBuilderException exposes typeName', () {
      const e = UnregisteredBuilderException('FooBar()', 'FooBar');
      expect(e.typeName, 'FooBar');
      expect(e.message, contains('FooBar'));
    });

    test('ArgumentException carries source', () {
      const e = ArgumentException('Text()', 'missing "data"');
      expect(e.source, 'Text()');
    });

    test('BindingException is a RuneException', () {
      const e = BindingException('userName', 'not in data');
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
}

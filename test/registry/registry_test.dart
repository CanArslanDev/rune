import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/source_span.dart';
import 'package:rune/src/registry/registry.dart';

void main() {
  group('Registry<T>', () {
    test('register + find returns the stored item', () {
      final r = Registry<String>()..register('foo', 'bar');
      expect(r.find('foo'), 'bar');
    });

    test('find returns null when absent', () {
      final r = Registry<String>();
      expect(r.find('nope'), isNull);
    });

    test('contains reflects registration', () {
      final r = Registry<int>();
      expect(r.contains('a'), isFalse);
      r.register('a', 1);
      expect(r.contains('a'), isTrue);
    });

    test(
      'register throws StateError on duplicate and includes key + runtimeType',
      () {
        final r = Registry<int>()..register('k', 1);
        expect(
          () => r.register('k', 2),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              allOf(contains('"k"'), contains('Registry<int>')),
            ),
          ),
        );
      },
    );

    test('registerAll adds multiple entries', () {
      final r = Registry<int>()..registerAll({'a': 1, 'b': 2});
      expect(r.find('a'), 1);
      expect(r.find('b'), 2);
    });

    test('require throws UnregisteredBuilderException when missing', () {
      final r = Registry<String>();
      expect(
        () => r.require('nope', source: 'Nope()'),
        throwsA(isA<UnregisteredBuilderException>()
            .having((e) => e.typeName, 'typeName', 'nope')
            .having((e) => e.source, 'source', 'Nope()'),),
      );
    });

    test('require returns item when present', () {
      final r = Registry<String>()..register('x', 'y');
      expect(r.require('x', source: 'X()'), 'y');
    });

    test('size reflects entry count', () {
      final r = Registry<int>();
      expect(r.size, 0);
      r
        ..register('a', 1)
        ..register('b', 2);
      expect(r.size, 2);
    });
  });

  group('Registry<T>.require — location threading', () {
    test('require with explicit location threads through to thrown exception',
        () {
      final r = Registry<String>();
      final span = SourceSpan.fromOffset('Nope()', 0, 4);
      expect(
        () => r.require('Nope', source: 'Nope()', location: span),
        throwsA(
          isA<UnregisteredBuilderException>()
              .having((e) => e.location, 'location', isNotNull)
              .having((e) => e.location!.line, 'location.line', 1)
              .having((e) => e.location!.column, 'location.column', 1)
              .having(
                (e) => e.location!.excerpt,
                'location.excerpt',
                'Nope()',
              ),
        ),
      );
    });
  });
}

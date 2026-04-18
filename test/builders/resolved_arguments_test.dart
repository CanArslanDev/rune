import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/exceptions.dart';

void main() {
  group('ResolvedArguments', () {
    test('empty constants have no entries', () {
      expect(ResolvedArguments.empty.positional, isEmpty);
      expect(ResolvedArguments.empty.named, isEmpty);
    });

    test('get<T> returns typed value or null', () {
      const args = ResolvedArguments(named: {'x': 42, 'y': 'hi'});
      expect(args.get<int>('x'), 42);
      expect(args.get<String>('y'), 'hi');
      expect(args.get<int>('missing'), isNull);
    });

    test('getOr<T> returns fallback when missing or null', () {
      const args = ResolvedArguments(named: {'x': null, 'y': 5});
      expect(args.getOr<int>('x', 99), 99);
      expect(args.getOr<int>('missing', 7), 7);
      expect(args.getOr<int>('y', 0), 5);
    });

    test('require<T> returns value when present and non-null', () {
      const args = ResolvedArguments(named: {'x': 'ok'});
      expect(args.require<String>('x', source: 'Foo()'), 'ok');
    });

    test('require<T> throws ArgumentException when absent', () {
      const args = ResolvedArguments.empty;
      expect(
        () => args.require<String>('x', source: 'Foo()'),
        throwsA(
          isA<ArgumentException>()
              .having((e) => e.source, 'source', 'Foo()'),
        ),
      );
    });

    test('require<T> throws ArgumentException when null', () {
      const args = ResolvedArguments(named: {'x': null});
      expect(
        () => args.require<String>('x', source: 'Foo()'),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('positionalAt<T> returns typed positional or null', () {
      const args = ResolvedArguments(positional: [1, 'two', 3.0]);
      expect(args.positionalAt<int>(0), 1);
      expect(args.positionalAt<String>(1), 'two');
      expect(args.positionalAt<double>(2), 3.0);
      expect(args.positionalAt<int>(99), isNull);
    });

    test('requirePositional<T> throws on out-of-range', () {
      const args = ResolvedArguments.empty;
      expect(
        () => args.requirePositional<int>(0, source: 'Foo()'),
        throwsA(isA<ArgumentException>()),
      );
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/registry/constant_registry.dart';

void main() {
  group('ConstantRegistry', () {
    test('register + resolve returns the stored value', () {
      final r = ConstantRegistry()..register('Colors', 'red', 0xFFFF0000);
      expect(r.resolve('Colors', 'red'), 0xFFFF0000);
    });

    test('resolve returns null for missing type', () {
      final r = ConstantRegistry();
      expect(r.resolve('Nope', 'x'), isNull);
    });

    test('resolve returns null for missing member', () {
      final r = ConstantRegistry()..register('Colors', 'red', 0xFFFF0000);
      expect(r.resolve('Colors', 'purple'), isNull);
    });

    test('contains reflects presence', () {
      final r = ConstantRegistry();
      expect(r.contains('Colors', 'red'), isFalse);
      r.register('Colors', 'red', 0xFFFF0000);
      expect(r.contains('Colors', 'red'), isTrue);
    });

    test('require returns value when present', () {
      final r = ConstantRegistry()..register('Axis', 'horizontal', 0);
      expect(r.require('Axis', 'horizontal', source: 'Axis.horizontal'), 0);
    });

    test('require throws ResolveException when missing', () {
      final r = ConstantRegistry();
      expect(
        () => r.require('Axis', 'vertical', source: 'Axis.vertical'),
        throwsA(
          isA<ResolveException>()
              .having((e) => e.source, 'source', 'Axis.vertical')
              .having((e) => e.message, 'message', contains('Axis.vertical')),
        ),
      );
    });

    test('register throws StateError on duplicate', () {
      final r = ConstantRegistry()..register('X', 'a', 1);
      expect(() => r.register('X', 'a', 2), throwsStateError);
    });

    test('registerAll seeds every entry', () {
      final r = ConstantRegistry()
        ..registerAll('Colors', const {'red': 0xFFFF0000, 'blue': 0xFF0000FF});
      expect(r.resolve('Colors', 'red'), 0xFFFF0000);
      expect(r.resolve('Colors', 'blue'), 0xFF0000FF);
    });

    test('registerAll retains pre-duplicate entries when later entry throws',
        () {
      final r = ConstantRegistry()..register('X', 'a', 1);
      expect(
        () => r.registerAll('X', const {'b': 2, 'a': 99, 'c': 3}),
        throwsStateError,
      );
      // `b` landed before the duplicate `a` fired; `c` did not.
      expect(r.resolve('X', 'b'), 2);
      expect(r.resolve('X', 'a'), 1, reason: 'pre-existing value untouched');
      expect(r.contains('X', 'c'), isFalse);
    });

    test('contains returns true when registered value is null', () {
      final r = ConstantRegistry()..register('X', 'y', null);
      expect(r.contains('X', 'y'), isTrue);
      expect(r.resolve('X', 'y'), isNull);
    });

    test('size counts total members across all types', () {
      final r = ConstantRegistry();
      expect(r.size, 0);
      r
        ..registerAll('Colors', const {'red': 0xFFFF0000, 'blue': 0xFF0000FF})
        ..register('Axis', 'horizontal', 0);
      expect(r.size, 3);
    });
  });
}

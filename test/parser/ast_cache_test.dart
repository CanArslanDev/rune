import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/parser/ast_cache.dart';
import 'package:rune/src/parser/dart_parser.dart';

void main() {
  group('AstCache', () {
    final parser = DartParser();

    test('returns null on miss', () {
      final cache = AstCache();
      expect(cache.get('42'), isNull);
    });

    test('put then get returns the same instance', () {
      final cache = AstCache();
      final expr = parser.parse('42');
      cache.put('42', expr);
      expect(identical(cache.get('42'), expr), isTrue);
    });

    test('repeated put updates LRU order, size stays 1', () {
      final cache = AstCache()
        ..put('42', parser.parse('42'))
        ..put('42', parser.parse('42'));
      expect(cache.size, 1);
    });

    test('evicts least-recently-used when over maxSize', () {
      final cache = AstCache(maxSize: 2)
        ..put('a', parser.parse("'a'"))
        ..put('b', parser.parse("'b'"))
        ..get('a') // touch 'a' → 'b' is now LRU
        ..put('c', parser.parse("'c'"));
      expect(cache.get('b'), isNull); // evicted
      expect(cache.get('a'), isNotNull);
      expect(cache.get('c'), isNotNull);
    });

    test('clear empties the cache', () {
      final cache = AstCache()
        ..put('a', parser.parse('1'))
        ..put('b', parser.parse('2'))
        ..clear();
      expect(cache.size, 0);
      expect(cache.get('a'), isNull);
    });

    test('zero or negative maxSize fails fast', () {
      expect(() => AstCache(maxSize: 0), throwsAssertionError);
      expect(() => AstCache(maxSize: -1), throwsAssertionError);
    });
  });
}

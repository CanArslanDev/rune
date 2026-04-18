import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/parser/dart_parser.dart';
import 'package:rune/src/resolver/literal_resolver.dart';

void main() {
  final parser = DartParser();
  final resolver = LiteralResolver();

  Literal parseLit(String source) => parser.parse(source) as Literal;

  group('LiteralResolver', () {
    test('IntegerLiteral → int', () {
      expect(resolver.resolve(parseLit('42')), 42);
    });

    test('DoubleLiteral → double', () {
      expect(resolver.resolve(parseLit('3.14')), 3.14);
    });

    test('BooleanLiteral → bool', () {
      expect(resolver.resolve(parseLit('true')), isTrue);
      expect(resolver.resolve(parseLit('false')), isFalse);
    });

    test('NullLiteral → null', () {
      expect(resolver.resolve(parseLit('null')), isNull);
    });

    test('SimpleStringLiteral → String (single quotes)', () {
      expect(resolver.resolve(parseLit("'hello'")), 'hello');
    });

    test('SimpleStringLiteral → String (double quotes)', () {
      expect(resolver.resolve(parseLit('"hello"')), 'hello');
    });

    test('StringInterpolation throws ResolveException in Phase 1', () {
      expect(
        () => resolver.resolve(parseLit("'\$name'")),
        throwsA(isA<ResolveException>()),
      );
    });

    test('AdjacentStrings concatenates in source order', () {
      expect(resolver.resolve(parseLit("'hello ' 'world'")), 'hello world');
    });

    test('AdjacentStrings with three parts', () {
      expect(resolver.resolve(parseLit("'a' 'b' 'c'")), 'abc');
    });
  });
}

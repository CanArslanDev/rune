import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/parser/dart_parser.dart';

void main() {
  group('DartParser', () {
    final parser = DartParser();

    test('parses an integer literal', () {
      final Expression e = parser.parse('42');
      expect(e, isA<IntegerLiteral>());
      expect((e as IntegerLiteral).value, 42);
    });

    test('parses a string literal', () {
      final Expression e = parser.parse("'hello'");
      expect(e, isA<SimpleStringLiteral>());
      expect((e as SimpleStringLiteral).value, 'hello');
    });

    test('parses a simple instance creation', () {
      // Without type resolution, Text('hi') is parsed as a MethodInvocation.
      // Use `new` to force InstanceCreationExpression.
      final Expression e = parser.parse("new Text('hi')");
      expect(e, isA<InstanceCreationExpression>());
      final ic = e as InstanceCreationExpression;
      expect(ic.constructorName.type.name2.lexeme, 'Text');
      expect(ic.constructorName.name, isNull);
      expect(ic.argumentList.arguments, hasLength(1));
    });

    test('parses a named constructor', () {
      // Without resolution, EdgeInsets.all(16) is a MethodInvocation.
      // Use `new` to force InstanceCreationExpression.
      // The parser (without resolution) treats `EdgeInsets` as an
      // ImportPrefixReference and `all` as the NamedType.name2.
      final Expression e = parser.parse('new EdgeInsets.all(16)');
      expect(e, isA<InstanceCreationExpression>());
      final ic = e as InstanceCreationExpression;
      final namedType = ic.constructorName.type;
      // Class name is in importPrefix when written as Prefix.Constructor.
      expect(namedType.importPrefix?.name.lexeme, 'EdgeInsets');
      expect(namedType.name2.lexeme, 'all');
    });

    test('parses a nested tree (unresolved → MethodInvocation)', () {
      // Without type resolution, call-syntax constructors are MethodInvocations.
      final Expression e = parser.parse(
        "Column(children: [Text('a'), Text('b')])",
      );
      expect(e, isA<MethodInvocation>());
    });

    test('parses a bare constructor call as MethodInvocation (no `new`)', () {
      final Expression e = parser.parse("Text('hi')");
      expect(e, isA<MethodInvocation>());
      final m = e as MethodInvocation;
      expect(m.target, isNull);
      expect(m.methodName.name, 'Text');
      expect(m.argumentList.arguments, hasLength(1));
      expect(m.argumentList.arguments.first, isA<SimpleStringLiteral>());
    });

    test('parses a bare named constructor call as MethodInvocation', () {
      final Expression e = parser.parse('EdgeInsets.all(16)');
      expect(e, isA<MethodInvocation>());
      final m = e as MethodInvocation;
      expect(m.target, isA<SimpleIdentifier>());
      expect((m.target! as SimpleIdentifier).name, 'EdgeInsets');
      expect(m.methodName.name, 'all');
      expect(m.argumentList.arguments, hasLength(1));
    });

    test('tolerates trailing semicolon', () {
      expect(() => parser.parse('42;'), returnsNormally);
    });

    test('tolerates surrounding whitespace', () {
      expect(() => parser.parse('  42  '), returnsNormally);
    });

    test('throws ParseException on empty input', () {
      expect(
        () => parser.parse('   '),
        throwsA(isA<ParseException>()),
      );
    });

    test('throws ParseException on syntactically invalid input', () {
      expect(
        () => parser.parse('Text('),
        throwsA(isA<ParseException>()
            .having((e) => e.source, 'source', 'Text('),),
      );
    });
  });
}

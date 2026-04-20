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

  group('RuneException.toString with location', () {
    const span = SourceSpan(
      offset: 5,
      length: 4,
      line: 1,
      column: 6,
      excerpt: 'Text(bad)',
    );

    test(
      'ParseException without location preserves one-line format',
      () {
        expect(
          const ParseException('Text(', 'unexpected EOF').toString(),
          'ParseException: unexpected EOF (source: "Text(")',
        );
      },
    );

    test(
      'ResolveException without location preserves one-line format',
      () {
        expect(
          const ResolveException('foo', 'not supported').toString(),
          'ResolveException: not supported (source: "foo")',
        );
      },
    );

    test(
      'UnregisteredBuilderException without location preserves one-line format',
      () {
        expect(
          const UnregisteredBuilderException('FooBar()', 'FooBar').toString(),
          'UnregisteredBuilderException: No builder registered for type '
          '"FooBar" (source: "FooBar()")',
        );
      },
    );

    test(
      'ArgumentException without location preserves one-line format',
      () {
        expect(
          const ArgumentException('Text()', 'missing "data"').toString(),
          'ArgumentException: missing "data" (source: "Text()")',
        );
      },
    );

    test(
      'BindingException without location preserves one-line format',
      () {
        expect(
          const BindingException('userName', 'not in data').toString(),
          'BindingException: not in data (source: "userName")',
        );
      },
    );

    test('ParseException with location renders the pointer block', () {
      const exc = ParseException('Text(bad)', 'bad', location: span);
      final str = exc.toString();
      expect(str, contains('ParseException: bad (source: "Text(bad)")'));
      expect(str, contains('at line 1, column 6'));
      expect(str, contains('    Text(bad)'));
      expect(str, contains('^^^^'));
    });

    test('pointer block lines are indented by exactly 4 spaces', () {
      const exc = ParseException('Text(bad)', 'bad', location: span);
      final lines = exc.toString().split('\n');
      // Line 0: one-line summary
      // Line 1: '  at line X, column Y:'
      // Line 2: '    <excerpt>'
      // Line 3: '    <indent>^^^^'
      expect(lines.length, 4);
      expect(lines[1], '  at line 1, column 6:');
      expect(lines[2].startsWith('    '), isTrue);
      expect(lines[2], '    Text(bad)');
      expect(lines[3].startsWith('    '), isTrue);
      // Caret line: 4-space base indent + 5 spaces (column-1) + '^^^^'
      expect(lines[3], '         ^^^^');
    });

    test('ResolveException with location fires the helper', () {
      const exc = ResolveException('bar', 'nope', location: span);
      expect(exc.toString(), contains('at line '));
    });

    test('UnregisteredBuilderException with location fires the helper', () {
      const exc =
          UnregisteredBuilderException('FooBar()', 'FooBar', location: span);
      expect(exc.toString(), contains('at line '));
    });

    test('ArgumentException with location fires the helper', () {
      const exc =
          ArgumentException('Text()', 'missing "data"', location: span);
      expect(exc.toString(), contains('at line '));
    });

    test('BindingException with location fires the helper', () {
      const exc =
          BindingException('userName', 'not in data', location: span);
      expect(exc.toString(), contains('at line '));
    });

    test(
      'caret block format matches SourceSpan.toPointerString exactly',
      () {
        const exc = ParseException('Text(bad)', 'bad', location: span);
        final full = exc.toString();
        final thirdLineOnward = full.split('\n').sublist(2).join('\n');
        final expectedBlock = span
            .toPointerString()
            .split('\n')
            .map((l) => '    $l')
            .join('\n');
        expect(thirdLineOnward, expectedBlock);
      },
    );
  });

  group('withSuggestion factories', () {
    test('UnregisteredBuilderException.withSuggestion adds trailer on match',
        () {
      final exc = UnregisteredBuilderException.withSuggestion(
        'Colums()',
        'Colums',
        const ['Column', 'Row'],
      );
      expect(exc.typeName, 'Colums');
      expect(exc.message, contains('did you mean "Column"?'));
    });

    test('UnregisteredBuilderException.withSuggestion omits trailer on miss',
        () {
      final exc = UnregisteredBuilderException.withSuggestion(
        'Zzzzzz()',
        'Zzzzzz',
        const ['Column', 'Row'],
      );
      expect(exc.message, isNot(contains('did you mean')));
    });

    test('ResolveException.withSuggestion composes baseMessage + trailer', () {
      final exc = ResolveException.withSuggestion(
        source: 'Colors.redd',
        baseMessage: 'Unknown constant "Colors.redd"',
        candidate: 'redd',
        candidates: const ['red', 'blue'],
      );
      expect(exc.message, startsWith('Unknown constant "Colors.redd"'));
      expect(exc.message, endsWith('(did you mean "red"?)'));
    });

    test('BindingException.withSuggestion carries location through', () {
      const span = SourceSpan(
        offset: 0,
        length: 5,
        line: 1,
        column: 1,
        excerpt: 'userNam',
      );
      final exc = BindingException.withSuggestion(
        source: 'userNam',
        baseMessage: 'Unknown identifier "userNam"',
        candidate: 'userNam',
        candidates: const ['userName'],
        location: span,
      );
      expect(exc.location, same(span));
      expect(exc.message, contains('did you mean "userName"?'));
    });
  });
}

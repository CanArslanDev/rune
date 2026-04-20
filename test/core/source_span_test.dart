import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/core/source_span.dart';

void main() {
  group('SourceSpan equality', () {
    test('two spans with identical fields are equal and share hashCode', () {
      const a = SourceSpan(
        offset: 3,
        length: 4,
        line: 2,
        column: 5,
        excerpt: 'hello',
      );
      const b = SourceSpan(
        offset: 3,
        length: 4,
        line: 2,
        column: 5,
        excerpt: 'hello',
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('different offset makes spans unequal', () {
      const a = SourceSpan(
        offset: 3,
        length: 4,
        line: 2,
        column: 5,
        excerpt: 'hello',
      );
      const b = SourceSpan(
        offset: 4,
        length: 4,
        line: 2,
        column: 5,
        excerpt: 'hello',
      );
      expect(a, isNot(equals(b)));
    });

    test('different length makes spans unequal', () {
      const a = SourceSpan(
        offset: 3,
        length: 4,
        line: 2,
        column: 5,
        excerpt: 'hello',
      );
      const b = SourceSpan(
        offset: 3,
        length: 5,
        line: 2,
        column: 5,
        excerpt: 'hello',
      );
      expect(a, isNot(equals(b)));
    });

    test('different line makes spans unequal', () {
      const a = SourceSpan(
        offset: 3,
        length: 4,
        line: 2,
        column: 5,
        excerpt: 'hello',
      );
      const b = SourceSpan(
        offset: 3,
        length: 4,
        line: 3,
        column: 5,
        excerpt: 'hello',
      );
      expect(a, isNot(equals(b)));
    });

    test('different column makes spans unequal', () {
      const a = SourceSpan(
        offset: 3,
        length: 4,
        line: 2,
        column: 5,
        excerpt: 'hello',
      );
      const b = SourceSpan(
        offset: 3,
        length: 4,
        line: 2,
        column: 6,
        excerpt: 'hello',
      );
      expect(a, isNot(equals(b)));
    });

    test('different excerpt makes spans unequal', () {
      const a = SourceSpan(
        offset: 3,
        length: 4,
        line: 2,
        column: 5,
        excerpt: 'hello',
      );
      const b = SourceSpan(
        offset: 3,
        length: 4,
        line: 2,
        column: 5,
        excerpt: 'world',
      );
      expect(a, isNot(equals(b)));
    });
  });

  group('SourceSpan.fromOffset basic', () {
    test('single-line source at start', () {
      final span = SourceSpan.fromOffset('abc', 0, 1);
      expect(span.line, 1);
      expect(span.column, 1);
      expect(span.excerpt, 'abc');
      expect(span.offset, 0);
      expect(span.length, 1);
    });

    test('single-line source at non-zero offset', () {
      final span = SourceSpan.fromOffset('abc', 2, 1);
      expect(span.line, 1);
      expect(span.column, 3);
      expect(span.excerpt, 'abc');
      expect(span.offset, 2);
      expect(span.length, 1);
    });
  });

  group('SourceSpan.fromOffset multi-line', () {
    test(r'offset 4 in "abc\ndef" → line 2, col 1, excerpt "def"', () {
      final span = SourceSpan.fromOffset('abc\ndef', 4, 1);
      expect(span.line, 2);
      expect(span.column, 1);
      expect(span.excerpt, 'def');
    });

    test(r'offset 8 in "abc\ndef\nghi" → line 3, col 1, excerpt "ghi"', () {
      final span = SourceSpan.fromOffset('abc\ndef\nghi', 8, 3);
      expect(span.line, 3);
      expect(span.column, 1);
      expect(span.excerpt, 'ghi');
      expect(span.length, 3);
    });
  });

  group('SourceSpan.fromOffset empty excerpt', () {
    test('offset on blank line between newlines', () {
      final span = SourceSpan.fromOffset('abc\n\nxyz', 4, 0);
      expect(span.line, 2);
      expect(span.column, 1);
      expect(span.excerpt, '');
    });
  });

  group('SourceSpan.fromOffset range validation', () {
    test('offset > source.length throws RangeError', () {
      expect(
        () => SourceSpan.fromOffset('abc', 5, 1),
        throwsA(isA<RangeError>()),
      );
    });

    test('negative offset throws RangeError', () {
      expect(
        () => SourceSpan.fromOffset('abc', -1, 1),
        throwsA(isA<RangeError>()),
      );
    });

    test('negative length throws RangeError', () {
      expect(
        () => SourceSpan.fromOffset('abc', 0, -1),
        throwsA(isA<RangeError>()),
      );
    });
  });

  group('SourceSpan.toPointerString', () {
    test('single-line, offset 0 produces aligned carets', () {
      final span = SourceSpan.fromOffset('Text(123)', 0, 4);
      expect(span.toPointerString(), 'Text(123)\n^^^^');
    });

    test('multi-line points inside the correct line', () {
      final span = SourceSpan.fromOffset('a\nbbb\nc', 2, 3);
      expect(span.toPointerString(), 'bbb\n^^^');
    });

    test('column offset indents the caret run with spaces', () {
      final span = SourceSpan.fromOffset('  Text', 2, 4);
      expect(span.toPointerString(), '  Text\n  ^^^^');
    });

    test('length 0 still renders at least one caret', () {
      final span = SourceSpan.fromOffset('abc', 1, 0);
      expect(span.toPointerString(), 'abc\n ^');
    });

    test('caret run clamped to excerpt tail (no overflow)', () {
      // excerpt "abc" length 3; column 2 means tail length = 3-(2-1) = 2.
      // length 10 should clamp to 2 carets.
      final span = SourceSpan.fromOffset('abc', 1, 10);
      expect(span.toPointerString(), 'abc\n ^^');
    });
  });

  group('SourceSpan.fromAstOffset', () {
    test('empty source returns zero-length span at origin', () {
      final span = SourceSpan.fromAstOffset('', 19, 5);
      expect(span.offset, 0);
      expect(span.length, 0);
      expect(span.line, 1);
      expect(span.column, 1);
      expect(span.excerpt, '');
    });

    test('pre-wrapper AST offset falls back to origin zero-length span', () {
      // astOffset 10 < wrapperPrefixLength 19 → pre-wrapper fallback.
      final span = SourceSpan.fromAstOffset('Text()', 10, 5);
      expect(span.offset, 0);
      expect(span.length, 0);
    });

    test(
      'normal rebased offset matches SourceSpan.fromOffset directly',
      () {
        final viaFactory = SourceSpan.fromAstOffset('Text()', 19 + 2, 3);
        final direct = SourceSpan.fromOffset('Text()', 2, 3);
        expect(viaFactory, equals(direct));
      },
    );

    test('EOF-shaped AST offset clamps to source length (length trims)', () {
      // Unclosed paren: analyzer reports offset past end by one.
      // 'Text(' length 5; astOffset 19 + 6 rebases to 6, clamped to 5.
      // Length 1 then clamps to max 0 (source.length - 5 == 0).
      final span = SourceSpan.fromAstOffset('Text(', 19 + 6, 1);
      expect(span.offset, 5);
      expect(span.length, 0);
    });

    test('length overflow clamps to source.length - offset', () {
      // 'abc' length 3; astOffset 19 + 1 rebases to 1; length 10 clamps to 2.
      final span = SourceSpan.fromAstOffset('abc', 19 + 1, 10);
      expect(span.offset, 1);
      expect(span.length, 2);
    });

    test('multi-line rebasing preserves line, column, and excerpt', () {
      // 'abc\ndef' (length 7); astOffset 19 + 5 rebases to 5 → on 'def' at
      // line 2, column 2. Length 1 fits.
      final span = SourceSpan.fromAstOffset('abc\ndef', 19 + 5, 1);
      expect(span.offset, 5);
      expect(span.length, 1);
      expect(span.line, 2);
      expect(span.column, 2);
      expect(span.excerpt, 'def');
    });
  });

  group('SourceSpan.toString', () {
    test('contains line, column, offset, and length in deterministic form', () {
      const span = SourceSpan(
        offset: 7,
        length: 4,
        line: 3,
        column: 2,
        excerpt: 'Text()',
      );
      expect(
        span.toString(),
        'SourceSpan(L3:C2, offset=7, length=4)',
      );
    });
  });

  group('SourceSpan.toContextualPointer', () {
    const multiLineSource = 'Column(\n'
        '  children: [\n'
        '    Text("hi"),\n'
        '    Colums(),\n'
        '    Text("bye"),\n'
        '  ],\n'
        ')';

    test('contextLines: 0 reproduces toPointerString exactly', () {
      final span = SourceSpan.fromOffset(
        multiLineSource,
        multiLineSource.indexOf('Colums'),
        6,
      );
      expect(
        span.toContextualPointer(multiLineSource, contextLines: 0),
        span.toPointerString(),
      );
    });

    test('contextLines: 1 adds one line above and one line below', () {
      final span = SourceSpan.fromOffset(
        multiLineSource,
        multiLineSource.indexOf('Colums'),
        6,
      );
      final out = span.toContextualPointer(multiLineSource);
      final lines = out.split('\n');
      // Expected: Text("hi"), | Colums(), | carets | Text("bye"),
      expect(lines.length, 4);
      expect(lines[0].trim(), 'Text("hi"),');
      expect(lines[1].trim(), 'Colums(),');
      expect(lines[2].trim().startsWith('^'), isTrue);
      expect(lines[3].trim(), 'Text("bye"),');
    });

    test('contextLines: 3 widens the excerpt further', () {
      final span = SourceSpan.fromOffset(
        multiLineSource,
        multiLineSource.indexOf('Colums'),
        6,
      );
      final out = span.toContextualPointer(
        multiLineSource,
        contextLines: 3,
      );
      // Covers the whole source plus a caret row.
      expect(out, contains('Column('));
      expect(out, contains('children: ['));
      expect(out, contains('Text("hi"),'));
      expect(out, contains('Colums(),'));
      expect(out, contains('Text("bye"),'));
      expect(out, contains('^'));
    });

    test('span at start of source omits missing above lines', () {
      final span = SourceSpan.fromOffset(multiLineSource, 0, 6);
      final out = span.toContextualPointer(multiLineSource);
      final lines = out.split('\n');
      // First line of source has no "above" line — excerpt at lines[0],
      // caret at [1], below line at [2].
      expect(lines.length, 3);
      expect(lines[0], 'Column(');
      expect(lines[1].trim().startsWith('^'), isTrue);
      expect(lines[2].trim(), 'children: [');
    });

    test('span at end of source omits missing below lines', () {
      final span = SourceSpan.fromOffset(
        multiLineSource,
        multiLineSource.length - 1,
        1,
      );
      final out = span.toContextualPointer(multiLineSource);
      final lines = out.split('\n');
      expect(lines.length, 3);
      expect(lines[0].trim(), '],');
      expect(lines[1], ')');
      expect(lines[2].trim().startsWith('^'), isTrue);
    });

    test('empty fullSource falls back to toPointerString', () {
      const span = SourceSpan(
        offset: 0,
        length: 1,
        line: 1,
        column: 1,
        excerpt: 'x',
      );
      expect(span.toContextualPointer(''), span.toPointerString());
    });
  });
}

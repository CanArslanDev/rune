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
}

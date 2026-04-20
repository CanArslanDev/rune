import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/dev/rune_source_formatter.dart';

void main() {
  group('formatRuneSource', () {
    test('empty input returns empty string', () {
      expect(formatRuneSource(''), '');
      expect(formatRuneSource('   '), '');
    });

    test('trims surrounding whitespace and trailing semicolons', () {
      expect(formatRuneSource('  Text("hi"); '), 'Text("hi")');
    });

    test('single-line input that fits stays single-line', () {
      expect(formatRuneSource("Text('hi')"), "Text('hi')");
    });

    test('short Column(children: [...]) stays single-line', () {
      expect(
        formatRuneSource("Column(children: [Text('a'), Text('b')])"),
        "Column(children: [Text('a'), Text('b')])",
      );
    });

    test(
        'long call breaks each argument onto its own line with 2-space '
        'indentation', () {
      const input = 'Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, '
          'crossAxisAlignment: CrossAxisAlignment.center, '
          "children: [Text('one'), Text('two'), Text('three')])";
      final formatted = formatRuneSource(input);
      final lines = formatted.split('\n');
      // Header + one line per top-level argument + closer.
      expect(lines.first, 'Row(');
      expect(lines.last, ')');
      // Every argument line starts with exactly two spaces.
      for (final line in lines.sublist(1, lines.length - 1)) {
        expect(line.startsWith('  '), isTrue);
      }
    });

    test('multi-line layout carries a trailing comma on the last argument',
        () {
      const input = 'Container(width: 100, height: 200, child: '
          "Text('needs-a-lot-of-chars-to-force-the-break-"
          "onto-multiple-lines'))";
      final formatted = formatRuneSource(input);
      final lines = formatted.split('\n');
      // Penultimate line is the last argument; it should end with `,`.
      expect(lines[lines.length - 2].trimRight().endsWith(','), isTrue);
    });

    test('idempotent: formatting twice yields identical output', () {
      const input = "Column(children: [Text('one'), Text('two'), "
          "Text('three'), Text('four'), Text('five'), Text('six')])";
      final first = formatRuneSource(input);
      final second = formatRuneSource(first);
      expect(second, first);
    });

    test('list literal breaks with trailing comma when too long', () {
      const input = "[Text('alpha-one'), Text('beta-two'), "
          "Text('gamma-three'), Text('delta-four'), Text('epsilon-five')]";
      final formatted = formatRuneSource(input);
      expect(
        formatted.contains('\n'),
        isTrue,
        reason: 'expected multi-line break on long list literal:\n$formatted',
      );
      // Last element before the closing bracket keeps a trailing comma.
      final lines = formatted.split('\n');
      expect(lines[lines.length - 2].trimRight().endsWith(','), isTrue);
      expect(lines.last.trim(), ']');
    });

    test('short list literal stays on one line', () {
      expect(formatRuneSource('[1, 2, 3]'), '[1, 2, 3]');
    });

    test('unparseable input is returned trimmed but unchanged', () {
      expect(
        formatRuneSource('  this is !!! not @ dart  '),
        'this is !!! not @ dart',
      );
    });

    test('handles nested calls with correct indentation', () {
      const longLabel = 'some-long-label-to-make-the-line-break-occur';
      const input = "Outer(child: Inner(child: Leaf(label: '$longLabel')))";
      final formatted = formatRuneSource(input);
      final lines = formatted.split('\n');
      // Multiple levels of indentation appear.
      final indents = lines
          .map((l) => l.length - l.trimLeft().length)
          .where((i) => i > 0)
          .toSet();
      expect(
        indents.length >= 2,
        isTrue,
        reason: 'expected at least two distinct indent levels in\n$formatted',
      );
    });

    test('new-keyword form is preserved through formatting', () {
      expect(
        formatRuneSource('new Text("hi")'),
        'new Text("hi")',
      );
    });

    test('named constructor preserved (EdgeInsets.all)', () {
      expect(formatRuneSource('EdgeInsets.all(16)'), 'EdgeInsets.all(16)');
    });

    test('map literal short form stays single-line', () {
      expect(
        formatRuneSource("{'a': 1, 'b': 2}"),
        "{'a': 1, 'b': 2}",
      );
    });

    test('map literal breaks onto multiple lines when long', () {
      const input = "{'one': 'alpha-value', 'two': 'beta-value', "
          "'three': 'gamma-value', 'four': 'delta-value', "
          "'five': 'epsilon-value'}";
      final formatted = formatRuneSource(input);
      expect(
        formatted.contains('\n'),
        isTrue,
        reason: 'expected multi-line map on long literal:\n$formatted',
      );
      final lines = formatted.split('\n');
      // Closing brace is on its own line.
      expect(lines.last.trim(), '}');
    });

    test('set literal short form stays single-line', () {
      expect(formatRuneSource('{1, 2, 3}'), '{1, 2, 3}');
    });

    test('list with if-element keeps the if on its own line when breaking', () {
      const input =
          "[Text('a'), if (flag) Text('b'), if (otherFlag) Text('c'), "
          "Text('d'), Text('e'), Text('f'), Text('g')]";
      final formatted = formatRuneSource(input);
      expect(formatted.contains('\n'), isTrue);
      // Each `if (...)` element appears on its own line when broken.
      final lines = formatted.split('\n').map((l) => l.trim()).toList();
      final ifLines = lines.where((l) => l.startsWith('if (')).toList();
      expect(
        ifLines.length,
        2,
        reason: 'expected both if-elements on their own lines:\n$formatted',
      );
    });

    test('list with for-element preserves for-element when breaking', () {
      const input =
          "[Text('header'), for (final item in items) Text(item), "
          "Text('alpha'), Text('beta'), Text('gamma')]";
      final formatted = formatRuneSource(input);
      // The for-element should still be present in some form.
      expect(formatted.contains('for (final item in items)'), isTrue);
    });

    test('string interpolation is preserved across formatting', () {
      const input = r"Text('Hello, ${name}!')";
      expect(formatRuneSource(input), input);
    });

    test('ternary stays single-line when it fits', () {
      expect(
        formatRuneSource('flag ? 1 : 2'),
        'flag ? 1 : 2',
      );
    });

    test('arrow closure body is preserved', () {
      const input = '(ctx, state) => Text(state.name)';
      expect(formatRuneSource(input), input);
    });

    test('empty argument list stays compact', () {
      expect(formatRuneSource('Divider()'), 'Divider()');
      expect(formatRuneSource('SizedBox.shrink()'), 'SizedBox.shrink()');
    });

    test('deeply nested calls get progressive indent when broken', () {
      // Force a break with a long leaf label so the full chain must
      // wrap; check that indentation grows by 2 spaces per level.
      const longLabel = 'some-very-long-leaf-label-that-forces-a-break';
      const input = 'Outer(child: Middle(child: Inner(child: '
          "Leaf(label: '$longLabel'))))";
      final formatted = formatRuneSource(input);
      final lines = formatted.split('\n');
      final indents = lines
          .map((l) => l.length - l.trimLeft().length)
          .where((i) => i > 0)
          .toList();
      // Expect at least three distinct levels: 2 / 4 / 6 spaces.
      expect(
        indents.toSet().length >= 3,
        isTrue,
        reason:
            'expected >=3 distinct indent levels on deep chain:\n$formatted',
      );
    });
  });
}

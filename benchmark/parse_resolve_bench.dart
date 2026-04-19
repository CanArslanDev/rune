// benchmark/parse_resolve_bench.dart
//
// Usage:
//   flutter test benchmark/parse_resolve_bench.dart
//
// Measures parse + resolve time for a canonical ~30-node widget tree
// over N iterations. Reports mean / median / p95 / max. Does NOT
// exercise Flutter's build phase (that depends on the host widget
// tree). For end-to-end widget render timing, use flutter's
// devtools profiler on a RuneView.

// ignore_for_file: implementation_imports, avoid_print

import 'package:rune/rune.dart';
import 'package:rune/src/parser/ast_cache.dart';
import 'package:rune/src/parser/dart_parser.dart';
import 'package:rune/src/resolver/expression_resolver.dart';
import 'package:rune/src/resolver/identifier_resolver.dart';
import 'package:rune/src/resolver/invocation_resolver.dart';
import 'package:rune/src/resolver/literal_resolver.dart';
import 'package:rune/src/resolver/property_resolver.dart';

const String _canonicalSource = """
  Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text('Hello, world!'),
      SizedBox(height: 8),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text('Line 1'),
      ),
      Container(
        padding: EdgeInsets.all(4),
        child: Text('Line 2'),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Left'),
          Text('Center'),
          Text('Right'),
        ],
      ),
      SizedBox(height: 16),
      Container(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Text('Nested 1'),
            Text('Nested 2'),
            Text('Nested 3'),
          ],
        ),
      ),
    ],
  )
""";

const int _warmupIterations = 50;
const int _measuredIterations = 500;
const int _budgetMicros = 16000; // 16ms at 60fps

void main() {
  final parser = DartParser();
  final cache = AstCache();
  final literalResolver = LiteralResolver();
  final identifierResolver = IdentifierResolver();
  final expressionResolver =
      ExpressionResolver(literalResolver, identifierResolver);
  final invocationResolver = InvocationResolver(expressionResolver);
  final propertyResolver = PropertyResolver(expressionResolver);
  expressionResolver
    ..bind(invocationResolver)
    ..bindProperty(propertyResolver);

  final config = RuneConfig.defaults();
  final ctx = RuneContext(
    widgets: config.widgets,
    values: config.values,
    data: RuneDataContext.empty,
    events: RuneEventDispatcher(),
    constants: config.constants,
    extensions: config.extensions,
    components: ComponentRegistry(),
    source: _canonicalSource,
  );

  // Warmup — populates cache, JITs.
  for (var i = 0; i < _warmupIterations; i++) {
    cache.clear();
    final ast = parser.parse(_canonicalSource);
    cache.put(_canonicalSource, ast);
    expressionResolver.resolve(ast, ctx);
  }

  // Measured runs with fresh cache each iteration (cold path).
  final coldTimings = <int>[];
  for (var i = 0; i < _measuredIterations; i++) {
    cache.clear();
    final sw = Stopwatch()..start();
    final ast = parser.parse(_canonicalSource);
    cache.put(_canonicalSource, ast);
    expressionResolver.resolve(ast, ctx);
    sw.stop();
    coldTimings.add(sw.elapsedMicroseconds);
  }

  // Measured runs with warm cache (hot path).
  cache.clear();
  final initialAst = parser.parse(_canonicalSource);
  cache.put(_canonicalSource, initialAst);
  final warmTimings = <int>[];
  for (var i = 0; i < _measuredIterations; i++) {
    final sw = Stopwatch()..start();
    final ast = cache.get(_canonicalSource)!;
    expressionResolver.resolve(ast, ctx);
    sw.stop();
    warmTimings.add(sw.elapsedMicroseconds);
  }

  _reportStats('COLD (cache miss — parse + resolve)', coldTimings);
  _reportStats('WARM (cache hit — resolve only)', warmTimings);

  // Soft budget check against cold p95.
  coldTimings.sort();
  final p95Cold = coldTimings[(coldTimings.length * 95) ~/ 100];
  if (p95Cold > _budgetMicros) {
    print(
      '\n⚠  COLD p95 ($p95Cold\u00b5s) exceeds 16ms budget '
      '($_budgetMicros\u00b5s). Investigate parser/resolver hotspots.',
    );
  } else {
    print('\n\u2713  COLD p95 ($p95Cold\u00b5s) within 16ms budget.');
  }
}

void _reportStats(String label, List<int> timings) {
  timings.sort();
  final mean = timings.reduce((a, b) => a + b) / timings.length;
  final p50 = timings[timings.length ~/ 2];
  final p95 = timings[(timings.length * 95) ~/ 100];
  final p99 = timings[(timings.length * 99) ~/ 100];
  final max = timings.last;
  final min = timings.first;
  print(
    '$label over ${timings.length} iterations:\n'
    '  min    = $min\u00b5s\n'
    '  p50    = $p50\u00b5s\n'
    '  mean   = ${mean.toStringAsFixed(1)}\u00b5s\n'
    '  p95    = $p95\u00b5s\n'
    '  p99    = $p99\u00b5s\n'
    '  max    = $max\u00b5s',
  );
}

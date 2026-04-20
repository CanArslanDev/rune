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

/// Richer source exercising v1.x features: string interpolation,
/// deep dot-paths, `for`-elements, `if`-elements, operators, and
/// runtime member access. Represents a realistic "shopping cart"
/// screen closer to what a real Rune consumer might author post
/// v1.15+.
const String _richSource = r'''
  Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Cart (${cart.items.length} items)',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        if (cart.items.isEmpty)
          Center(child: Text('Your cart is empty.')),
        for (final item in cart.items)
          ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text(item.name.toUpperCase()),
            subtitle: Text('\$${item.price}'),
            trailing: TextButton(
              onPressed: 'remove',
              child: Text('Remove'),
            ),
          ),
        Divider(),
        if (cart.items.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal: \$${cart.subtotal}'),
              ElevatedButton(
                onPressed: cart.items.length > 0 ? 'checkout' : 'noop',
                child: Text('Checkout'),
              ),
            ],
          ),
        if (cart.items.length >= 3)
          Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text('Free shipping unlocked!'),
          ),
      ],
    ),
  )
''';

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
  final richData = <String, Object?>{
    'cart': <String, Object?>{
      'items': <Map<String, Object?>>[
        <String, Object?>{'id': 1, 'name': 'wireless mouse', 'price': 19},
        <String, Object?>{'id': 2, 'name': 'mechanical keyboard', 'price': 129},
        <String, Object?>{'id': 3, 'name': '27" monitor', 'price': 349},
        <String, Object?>{'id': 4, 'name': 'usb-c hub', 'price': 45},
      ],
      'subtotal': 542,
    },
  };

  RuneContext contextFor(String source, {Map<String, Object?>? data}) {
    return RuneContext(
      widgets: config.widgets,
      values: config.values,
      data: RuneDataContext(data ?? const <String, Object?>{}),
      events: RuneEventDispatcher(),
      constants: config.constants,
      extensions: config.extensions,
      components: ComponentRegistry(),
      source: source,
    );
  }

  _runCase(
    label: 'Canonical 30-node tree',
    source: _canonicalSource,
    parser: parser,
    cache: cache,
    resolver: expressionResolver,
    context: contextFor(_canonicalSource),
  );

  print('');

  _runCase(
    label: 'Rich source (interpolation, for/if elements, dot-paths)',
    source: _richSource,
    parser: parser,
    cache: AstCache(),
    resolver: expressionResolver,
    context: contextFor(_richSource, data: richData),
  );
}

void _runCase({
  required String label,
  required String source,
  required DartParser parser,
  required AstCache cache,
  required ExpressionResolver resolver,
  required RuneContext context,
}) {
  print('=== $label ===');

  for (var i = 0; i < _warmupIterations; i++) {
    cache.clear();
    final ast = parser.parse(source);
    cache.put(source, ast);
    resolver.resolve(ast, context);
  }

  final coldTimings = <int>[];
  for (var i = 0; i < _measuredIterations; i++) {
    cache.clear();
    final sw = Stopwatch()..start();
    final ast = parser.parse(source);
    cache.put(source, ast);
    resolver.resolve(ast, context);
    sw.stop();
    coldTimings.add(sw.elapsedMicroseconds);
  }

  cache.clear();
  final initialAst = parser.parse(source);
  cache.put(source, initialAst);
  final warmTimings = <int>[];
  for (var i = 0; i < _measuredIterations; i++) {
    final sw = Stopwatch()..start();
    final ast = cache.get(source)!;
    resolver.resolve(ast, context);
    sw.stop();
    warmTimings.add(sw.elapsedMicroseconds);
  }

  _reportStats('COLD (cache miss, parse + resolve)', coldTimings);
  _reportStats('WARM (cache hit, resolve only)', warmTimings);

  coldTimings.sort();
  final p95Cold = coldTimings[(coldTimings.length * 95) ~/ 100];
  final headroom = (_budgetMicros / (p95Cold == 0 ? 1 : p95Cold)).round();
  if (p95Cold > _budgetMicros) {
    print(
      '\u26a0  COLD p95 ($p95Cold\u00b5s) exceeds 16ms budget '
      '($_budgetMicros\u00b5s). Investigate parser/resolver hotspots.',
    );
  } else {
    print(
      '\u2713  COLD p95 ($p95Cold\u00b5s) within 16ms budget '
      '(${headroom}x headroom).',
    );
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

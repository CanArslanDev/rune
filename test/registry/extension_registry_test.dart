import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/source_span.dart';
import 'package:rune/src/registry/extension_registry.dart';

import '../_helpers/test_context.dart';

void main() {
  group('ExtensionRegistry', () {
    test('register + resolve invokes handler with target', () {
      final r = ExtensionRegistry()
        ..register('double', (target, ctx) => (target! as num) * 2);
      expect(r.resolve('double', 21, testContext()), 42);
    });

    test('resolve returns null when property is absent', () {
      final r = ExtensionRegistry();
      expect(r.resolve('missing', 1, testContext()), isNull);
    });

    test('contains reflects presence', () {
      final r = ExtensionRegistry();
      expect(r.contains('px'), isFalse);
      r.register('px', (t, c) => t);
      expect(r.contains('px'), isTrue);
    });

    test('require returns value when present', () {
      final r = ExtensionRegistry()..register('id', (t, c) => t);
      expect(
        r.require('id', 'hello', testContext(), source: 'x.id'),
        'hello',
      );
    });

    test('require throws ResolveException when absent', () {
      final r = ExtensionRegistry();
      expect(
        () => r.require('nope', 1, testContext(), source: '1.nope'),
        throwsA(
          isA<ResolveException>()
              .having((e) => e.source, 'source', '1.nope')
              .having((e) => e.message, 'message', contains('nope')),
        ),
      );
    });

    test('register throws StateError on duplicate', () {
      final r = ExtensionRegistry()..register('k', (t, c) => t);
      expect(
        () => r.register('k', (t, c) => t),
        throwsStateError,
      );
    });

    test('handler may read from context', () {
      final r = ExtensionRegistry()
        ..register('hasData', (t, c) => c.data.has(t! as String));
      final ctx = testContext();
      expect(r.resolve('hasData', 'x', ctx), isFalse);
    });

    test('size reflects registered handlers', () {
      final r = ExtensionRegistry();
      expect(r.size, 0);
      r
        ..register('a', (t, c) => t)
        ..register('b', (t, c) => t);
      expect(r.size, 2);
    });
  });

  group('ExtensionRegistry.require — location threading', () {
    test('require with explicit location threads through to thrown exception',
        () {
      const source = 'Row(\n  children: [1.nope],\n)';
      final r = ExtensionRegistry();
      // "1.nope" starts after "Row(\n  children: [" at offset 18, length 6.
      final span = SourceSpan.fromOffset(source, 18, 6);
      expect(
        () => r.require(
          'nope',
          1,
          testContext(source: source),
          source: '1.nope',
          location: span,
        ),
        throwsA(
          isA<ResolveException>()
              .having((e) => e.location, 'location', isNotNull)
              .having((e) => e.location!.line, 'location.line', 2)
              .having(
                (e) => e.location!.excerpt,
                'location.excerpt',
                contains('1.nope'),
              ),
        ),
      );
    });
  });
}

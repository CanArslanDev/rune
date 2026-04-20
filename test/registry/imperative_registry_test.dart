import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';
import 'package:rune/src/registry/imperative_registry.dart';

import '../_helpers/test_context.dart';

Object? _handler(ResolvedArguments args, RuneContext ctx) => 'called';

Object? _otherHandler(ResolvedArguments args, RuneContext ctx) => 'other';

void main() {
  group('ImperativeRegistry', () {
    test('starts empty', () {
      final r = ImperativeRegistry();
      expect(r.bareNames, isEmpty);
      expect(r.prefixedTargets, isEmpty);
    });

    test('registerBare + findBare round-trip', () {
      final r = ImperativeRegistry()..registerBare('showToast', _handler);
      expect(r.findBare('showToast'), same(_handler));
      expect(r.findBare('absent'), isNull);
    });

    test('registerBare throws StateError on duplicate', () {
      final r = ImperativeRegistry()..registerBare('showToast', _handler);
      expect(
        () => r.registerBare('showToast', _otherHandler),
        throwsStateError,
      );
    });

    test('registerPrefixed + findPrefixed round-trip', () {
      final r = ImperativeRegistry()
        ..registerPrefixed('Router', 'go', _handler);
      expect(r.findPrefixed('Router', 'go'), same(_handler));
      expect(r.findPrefixed('Router', 'push'), isNull);
      expect(r.findPrefixed('Navigator', 'go'), isNull);
    });

    test('registerPrefixed allows multiple methods on same target', () {
      final r = ImperativeRegistry()
        ..registerPrefixed('Router', 'go', _handler)
        ..registerPrefixed('Router', 'push', _otherHandler);
      expect(r.findPrefixed('Router', 'go'), same(_handler));
      expect(r.findPrefixed('Router', 'push'), same(_otherHandler));
    });

    test('registerPrefixed throws StateError on duplicate (target, method)',
        () {
      final r = ImperativeRegistry()
        ..registerPrefixed('Router', 'go', _handler);
      expect(
        () => r.registerPrefixed('Router', 'go', _otherHandler),
        throwsStateError,
      );
    });

    test('bareNames + prefixedTargets expose inserted keys', () {
      final r = ImperativeRegistry()
        ..registerBare('showToast', _handler)
        ..registerBare('vibrate', _otherHandler)
        ..registerPrefixed('Router', 'go', _handler)
        ..registerPrefixed('Analytics', 'logEvent', _handler);
      expect(r.bareNames, unorderedEquals({'showToast', 'vibrate'}));
      expect(r.prefixedTargets, unorderedEquals({'Router', 'Analytics'}));
    });

    test('handlers are invocable with ResolvedArguments + RuneContext', () {
      Object? sink;
      final r = ImperativeRegistry()
        ..registerBare('doIt', (args, ctx) {
          sink = args.named['flag'];
          return null;
        });
      final handler = r.findBare('doIt');
      handler!(const ResolvedArguments(named: {'flag': true}), testContext());
      expect(sink, isTrue);
    });
  });
}

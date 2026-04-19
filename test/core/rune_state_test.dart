import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/core/rune_state.dart';

void main() {
  group('RuneState', () {
    test('constructor round-trips entries and get reads them', () {
      var fired = 0;
      final state = RuneState(
        entries: const {'x': 1, 'y': 'hello'},
        onMutation: () => fired++,
      );
      expect(state.get('x'), 1);
      expect(state.get('y'), 'hello');
      expect(state.get('absent'), isNull);
      expect(fired, 0);
    });

    test('has distinguishes present-null from absent', () {
      var fired = 0;
      final state = RuneState(
        entries: const {'present': null},
        onMutation: () => fired++,
      );
      expect(state.has('present'), isTrue);
      expect(state.has('absent'), isFalse);
      expect(state.get('present'), isNull);
      expect(fired, 0);
    });

    test('set updates the value and fires onMutation once', () {
      var fired = 0;
      final state = RuneState(
        entries: const {},
        onMutation: () => fired++,
      )..set('counter', 1);
      expect(state.get('counter'), 1);
      expect(fired, 1);
    });

    test('set with same value still fires onMutation', () {
      var fired = 0;
      RuneState(
        entries: const {'counter': 1},
        onMutation: () => fired++,
      ).set('counter', 1);
      expect(fired, 1);
    });

    test('setMany merges all entries and fires onMutation exactly once', () {
      var fired = 0;
      final state = RuneState(
        entries: const {'a': 1},
        onMutation: () => fired++,
      )..setMany({'a': 10, 'b': 20});
      expect(state.get('a'), 10);
      expect(state.get('b'), 20);
      expect(fired, 1);
    });

    test('remove on present key returns true and fires onMutation', () {
      var fired = 0;
      final state = RuneState(
        entries: const {'x': 1},
        onMutation: () => fired++,
      );
      expect(state.remove('x'), isTrue);
      expect(state.has('x'), isFalse);
      expect(fired, 1);
    });

    test('remove on absent key returns false and does NOT fire onMutation',
        () {
      var fired = 0;
      final state = RuneState(
        entries: const {'x': 1},
        onMutation: () => fired++,
      );
      final result = state.remove('absent');
      expect(result, isFalse);
      expect(fired, 0);
    });

    test('clear on non-empty fires onMutation; on empty does not', () {
      var fired = 0;
      final state = RuneState(
        entries: const {'a': 1, 'b': 2},
        onMutation: () => fired++,
      )..clear();
      expect(state.has('a'), isFalse);
      expect(state.has('b'), isFalse);
      expect(fired, 1);

      state.clear();
      expect(fired, 1, reason: 'clear on empty state should not fire');
    });

    test('entries exposes the backing map for resolver consumption', () {
      var fired = 0;
      final state = RuneState(
        entries: const {'a': 1, 'b': 2},
        onMutation: () => fired++,
      );
      expect(state.entries, isA<Map<String, Object?>>());
      expect(state.entries['a'], 1);
      expect(state.entries['b'], 2);
      // set must be visible via entries.
      state.set('a', 99);
      expect(state.entries['a'], 99);
    });

    test(
        'multiple sequential sets each fire onMutation once (no implicit '
        'batching)', () {
      var fired = 0;
      RuneState(
        entries: const {},
        onMutation: () => fired++,
      )
        ..set('a', 1)
        ..set('b', 2)
        ..set('c', 3);
      expect(fired, 3);
    });
  });
}

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';

void main() {
  group('RuneEventDispatcher', () {
    test('dispatch invokes registered handler', () {
      final d = RuneEventDispatcher();
      var count = 0;
      d
        ..register('click', () => count++)
        ..dispatch('click')
        ..dispatch('click');
      expect(count, 2);
    });

    test('dispatch passes positional args', () {
      final d = RuneEventDispatcher();
      final captured = <Object?>[];
      d
        ..register('submit', (String value, int n) {
          captured.addAll([value, n]);
        })
        ..dispatch('submit', ['hello', 42]);
      expect(captured, ['hello', 42]);
    });

    test('dispatching unknown event does not throw', () {
      final d = RuneEventDispatcher();
      expect(() => d.dispatch('nope'), returnsNormally);
    });

    test('dispatching unknown event emits debug warning', () {
      final d = RuneEventDispatcher();
      final logs = <String?>[];
      final previous = debugPrint;
      debugPrint = (String? msg, {int? wrapWidth}) => logs.add(msg);
      try {
        d.dispatch('nope');
      } finally {
        debugPrint = previous;
      }
      expect(logs.single, contains('nope'));
    });

    test('register overwrites existing handler', () {
      final d = RuneEventDispatcher();
      var which = '';
      d
        ..register('e', () => which = 'a')
        ..register('e', () => which = 'b')
        ..dispatch('e');
      expect(which, 'b');
    });

    test('arity mismatch is caught and logged, not rethrown', () {
      final d = RuneEventDispatcher()..register('oops', () => 1);
      final logs = <String?>[];
      final previous = debugPrint;
      debugPrint = (String? msg, {int? wrapWidth}) => logs.add(msg);
      try {
        expect(
          () => d.dispatch('oops', ['unexpected', 'args']),
          returnsNormally,
        );
      } finally {
        debugPrint = previous;
      }
      expect(logs, isNotEmpty);
      expect(logs.last, contains('oops'));
    });

    test('handler-thrown exception is caught and logged, not rethrown', () {
      final d = RuneEventDispatcher()
        ..register('boom', () => throw StateError('intentional'));
      final logs = <String?>[];
      final previous = debugPrint;
      debugPrint = (String? msg, {int? wrapWidth}) => logs.add(msg);
      try {
        expect(() => d.dispatch('boom'), returnsNormally);
      } finally {
        debugPrint = previous;
      }
      expect(logs, isNotEmpty);
      expect(logs.last, contains('boom'));
      expect(logs.last, contains('intentional'));
    });

    test('catch-all handler fires for every dispatch', () {
      final d = RuneEventDispatcher();
      final captured = <String>[];
      d
        ..setCatchAllHandler((name, args) => captured.add(name))
        ..dispatch('one')
        ..dispatch('two')
        ..dispatch('three');
      expect(captured, ['one', 'two', 'three']);
    });

    test('catch-all receives forwarded positional args', () {
      final d = RuneEventDispatcher();
      List<Object?>? captured;
      d
        ..setCatchAllHandler((name, args) => captured = args)
        ..dispatch('submit', ['hello', 42]);
      expect(captured, ['hello', 42]);
    });

    test('catch-all AND named handler both fire', () {
      final d = RuneEventDispatcher();
      var catchCount = 0;
      var namedCount = 0;
      d
        ..setCatchAllHandler((name, args) => catchCount++)
        ..register('click', () => namedCount++)
        ..dispatch('click');
      expect(catchCount, 1);
      expect(namedCount, 1);
    });

    test('setCatchAllHandler(null) clears the bridge', () {
      final d = RuneEventDispatcher();
      var count = 0;
      d
        ..setCatchAllHandler((_, __) => count++)
        ..dispatch('a')
        ..setCatchAllHandler(null)
        ..dispatch('b');
      expect(count, 1);
    });

    test('catch-all error is caught and logged, not rethrown', () {
      final d = RuneEventDispatcher()
        ..setCatchAllHandler((_, __) => throw StateError('boom-catch'));
      final logs = <String?>[];
      final previous = debugPrint;
      debugPrint = (String? msg, {int? wrapWidth}) => logs.add(msg);
      try {
        expect(() => d.dispatch('x'), returnsNormally);
      } finally {
        debugPrint = previous;
      }
      expect(logs.any((m) => m != null && m.contains('boom-catch')), isTrue);
    });

    test('dispatching unknown event with catch-all set does NOT emit the '
        'no-handler warning', () {
      final d = RuneEventDispatcher()..setCatchAllHandler((_, __) {});
      final logs = <String?>[];
      final previous = debugPrint;
      debugPrint = (String? msg, {int? wrapWidth}) => logs.add(msg);
      try {
        d.dispatch('unknown');
      } finally {
        debugPrint = previous;
      }
      expect(
        logs.any(
          (m) => m != null && m.contains('No handler registered'),
        ),
        isFalse,
        reason: 'catch-all acts as the handler; warning should be silent',
      );
    });
  });
}

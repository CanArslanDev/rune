import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';

void main() {
  group('RuneEventDispatcher', () {
    test('dispatch invokes registered handler', () {
      final d = RuneEventDispatcher();
      var count = 0;
      d.register('click', () => count++);
      d.dispatch('click');
      d.dispatch('click');
      expect(count, 2);
    });

    test('dispatch passes positional args', () {
      final d = RuneEventDispatcher();
      final captured = <Object?>[];
      d.register('submit', (String value, int n) {
        captured.addAll([value, n]);
      });
      d.dispatch('submit', ['hello', 42]);
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
      d.register('e', () => which = 'a');
      d.register('e', () => which = 'b');
      d.dispatch('e');
      expect(which, 'b');
    });

    test('arity mismatch is caught and logged, not rethrown', () {
      final d = RuneEventDispatcher();
      d.register('oops', () => 1);
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
      final d = RuneEventDispatcher();
      d.register('boom', () => throw StateError('intentional'));
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
  });
}

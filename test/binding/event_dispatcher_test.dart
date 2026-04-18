import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart' hide EventDispatcher;
import 'package:rune/src/binding/event_dispatcher.dart';

void main() {
  group('EventDispatcher', () {
    test('dispatch invokes registered handler', () {
      final d = EventDispatcher();
      var count = 0;
      d.register('click', () => count++);
      d.dispatch('click');
      d.dispatch('click');
      expect(count, 2);
    });

    test('dispatch passes positional args', () {
      final d = EventDispatcher();
      final captured = <Object?>[];
      d.register('submit', (String value, int n) {
        captured.addAll([value, n]);
      });
      d.dispatch('submit', ['hello', 42]);
      expect(captured, ['hello', 42]);
    });

    test('dispatching unknown event does not throw', () {
      final d = EventDispatcher();
      expect(() => d.dispatch('nope'), returnsNormally);
    });

    test('dispatching unknown event emits debug warning', () {
      final d = EventDispatcher();
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
      final d = EventDispatcher();
      var which = '';
      d.register('e', () => which = 'a');
      d.register('e', () => which = 'b');
      d.dispatch('e');
      expect(which, 'b');
    });
  });
}

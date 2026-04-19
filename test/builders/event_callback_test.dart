import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/builders/event_callback.dart';

void main() {
  group('voidEventCallback', () {
    test('returns null when eventName is null', () {
      final events = RuneEventDispatcher();
      expect(voidEventCallback(null, events), isNull);
    });

    test(
      'returns a non-null VoidCallback that dispatches with empty args',
      () {
        final events = RuneEventDispatcher();
        String? firedName;
        List<Object?>? firedArgs;
        events.setCatchAllHandler((name, args) {
          firedName = name;
          firedArgs = args;
        });
        final cb = voidEventCallback('tap', events);
        expect(cb, isNotNull);
        expect(cb, isA<VoidCallback>());
        cb!.call();
        expect(firedName, 'tap');
        expect(firedArgs, isEmpty);
      },
    );

    test('callback is a no-arg Function() (VoidCallback shape)', () {
      final events = RuneEventDispatcher();
      final cb = voidEventCallback('x', events);
      expect(cb, isA<void Function()>());
    });
  });

  group('valueEventCallback', () {
    test('returns null when eventName is null (bool)', () {
      final events = RuneEventDispatcher();
      expect(valueEventCallback<bool>(null, events), isNull);
    });

    test(
      'bool variant dispatches (name, [value]) with forwarded bool',
      () {
        final events = RuneEventDispatcher();
        String? firedName;
        List<Object?>? firedArgs;
        events.setCatchAllHandler((name, args) {
          firedName = name;
          firedArgs = args;
        });
        final cb = valueEventCallback<bool>('toggled', events);
        expect(cb, isNotNull);
        expect(cb, isA<ValueChanged<bool>>());
        cb!(true);
        expect(firedName, 'toggled');
        expect(firedArgs, <Object?>[true]);
      },
    );

    test('double variant dispatches forwarded double value', () {
      final events = RuneEventDispatcher();
      String? firedName;
      List<Object?>? firedArgs;
      events.setCatchAllHandler((name, args) {
        firedName = name;
        firedArgs = args;
      });
      final cb = valueEventCallback<double>('slid', events);
      expect(cb, isNotNull);
      cb!(0.5);
      expect(firedName, 'slid');
      expect(firedArgs, <Object?>[0.5]);
    });

    test(
      'Object? variant dispatches a forwarded explicit null (Radio tristate)',
      () {
        final events = RuneEventDispatcher();
        String? firedName;
        List<Object?>? firedArgs;
        events.setCatchAllHandler((name, args) {
          firedName = name;
          firedArgs = args;
        });
        final cb = valueEventCallback<Object?>('radio', events);
        expect(cb, isNotNull);
        cb!(null);
        expect(firedName, 'radio');
        expect(firedArgs, <Object?>[null]);
      },
    );
  });
}

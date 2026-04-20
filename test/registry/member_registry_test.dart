import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/registry/member_registry.dart';

import '../_helpers/test_context.dart';

class _Counter {
  int count = 0;
  void increment() => count += 1;
  void add(int delta) => count += delta;
}

class _SpecialCounter extends _Counter {
  String get label => 'special:$count';
}

class _Named extends ChangeNotifier {
  String name = 'Ada';
  void rename(String next) {
    name = next;
    notifyListeners();
  }
}

void main() {
  group('MemberRegistry', () {
    test('starts empty', () {
      final r = MemberRegistry();
      expect(r.resolveProperty(_Counter(), 'count', testContext()).$1, isFalse);
    });

    test('registerProperty + resolveProperty round-trip on exact type', () {
      final r = MemberRegistry()
        ..registerProperty<_Counter>(
          'count',
          (target, ctx) => target.count,
        );
      final target = _Counter()..count = 7;
      final (hit, value) = r.resolveProperty(target, 'count', testContext());
      expect(hit, isTrue);
      expect(value, 7);
    });

    test('registerProperty matches subtypes (is-check semantics)', () {
      final r = MemberRegistry()
        ..registerProperty<_Counter>(
          'count',
          (target, ctx) => target.count,
        );
      final target = _SpecialCounter()..count = 9;
      final (hit, value) = r.resolveProperty(target, 'count', testContext());
      expect(hit, isTrue);
      expect(value, 9);
    });

    test('different property names on the same type resolve independently', () {
      final r = MemberRegistry()
        ..registerProperty<_SpecialCounter>(
          'label',
          (t, _) => t.label,
        )
        ..registerProperty<_SpecialCounter>(
          'count',
          (t, _) => t.count,
        );
      final target = _SpecialCounter()..count = 3;
      expect(
        r.resolveProperty(target, 'label', testContext()).$2,
        'special:3',
      );
      expect(r.resolveProperty(target, 'count', testContext()).$2, 3);
    });

    test('resolveProperty returns (false, null) when type does not match', () {
      final r = MemberRegistry()
        ..registerProperty<_Counter>('count', (t, _) => t.count);
      final (hit, value) = r.resolveProperty(42, 'count', testContext());
      expect(hit, isFalse);
      expect(value, isNull);
    });

    test('resolveProperty returns (false, null) when name does not match', () {
      final r = MemberRegistry()
        ..registerProperty<_Counter>('count', (t, _) => t.count);
      final (hit, value) =
          r.resolveProperty(_Counter(), 'other', testContext());
      expect(hit, isFalse);
      expect(value, isNull);
    });

    test('registerMethod + invokeMethod round-trip (no args)', () {
      final r = MemberRegistry()
        ..registerMethod<_Counter>(
          'increment',
          (target, args, ctx) {
            target.increment();
            return null;
          },
        );
      final target = _Counter()..count = 5;
      final (hit, _) =
          r.invokeMethod(target, 'increment', const [], testContext());
      expect(hit, isTrue);
      expect(target.count, 6);
    });

    test('registerMethod + invokeMethod round-trip (with positional arg)', () {
      final r = MemberRegistry()
        ..registerMethod<_Counter>(
          'add',
          (target, args, ctx) {
            target.add(args.first! as int);
            return null;
          },
        );
      final target = _Counter()..count = 1;
      final (hit, _) = r.invokeMethod(target, 'add', const [4], testContext());
      expect(hit, isTrue);
      expect(target.count, 5);
    });

    test(
      'invokeMethod returns (false, null) when no registration matches',
      () {
        final r = MemberRegistry();
        final (hit, _) =
            r.invokeMethod(_Counter(), 'absent', const [], testContext());
        expect(hit, isFalse);
      },
    );

    test('ChangeNotifier subtype works end-to-end', () {
      final r = MemberRegistry()
        ..registerProperty<_Named>('name', (t, _) => t.name)
        ..registerMethod<_Named>(
          'rename',
          (t, args, _) {
            t.rename(args.first! as String);
            return null;
          },
        );
      final target = _Named();
      addTearDown(target.dispose);

      expect(r.resolveProperty(target, 'name', testContext()).$2, 'Ada');

      r.invokeMethod(target, 'rename', ['Grace'], testContext());
      expect(target.name, 'Grace');
      expect(r.resolveProperty(target, 'name', testContext()).$2, 'Grace');
    });

    test('registrations are first-match-wins on overlap', () {
      // Register two accessors for the same (type, name). The first one
      // wins.
      final r = MemberRegistry()
        ..registerProperty<_Counter>('count', (t, _) => 'first')
        ..registerProperty<_Counter>('count', (t, _) => 'second');
      expect(
        r.resolveProperty(_Counter(), 'count', testContext()).$2,
        'first',
      );
    });
  });
}

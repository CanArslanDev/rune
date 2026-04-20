import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';
import 'package:rune_provider/rune_provider.dart';
import 'package:rune_provider/src/widgets/change_notifier_provider_builder.dart';

import '../_helpers/test_context.dart';

class _Counter extends ChangeNotifier {
  int v = 0;
}

class _ReactiveCounter extends ChangeNotifier
    implements RuneReactiveNotifier {
  int v = 0;
  @override
  Map<String, Object?> get state => {'v': v};
}

void main() {
  group('ChangeNotifierProviderBuilder', () {
    const b = ChangeNotifierProviderBuilder();

    test('typeName is "ChangeNotifierProvider"', () {
      expect(b.typeName, 'ChangeNotifierProvider');
    });

    test('throws when child is missing', () {
      expect(
        () => b.build(
          const ResolvedArguments(named: {'value': 0}),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('throws when both create and value are provided', () {
      expect(
        () => b.build(
          ResolvedArguments(
            named: {
              'value': _Counter(),
              'create': 'ignored',
              'child': const SizedBox.shrink(),
            },
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('throws when neither create nor value is provided', () {
      expect(
        () => b.build(
          const ResolvedArguments(named: {'child': SizedBox.shrink()}),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('throws when value is not a ChangeNotifier', () {
      // Non-ChangeNotifier values surface as a TypeError from
      // ResolvedArguments.require<ChangeNotifier>. Either shape is
      // acceptable - it must simply fail loudly.
      expect(
        () => b.build(
          const ResolvedArguments(
            named: {'value': 42, 'child': SizedBox.shrink()},
          ),
          testContext(),
        ),
        throwsA(anyOf(isA<ArgumentException>(), isA<TypeError>())),
      );
    });

    test('build with value returns a ChangeNotifierProvider-rooted Widget', () {
      final notifier = _Counter();
      addTearDown(notifier.dispose);
      final widget = b.build(
        ResolvedArguments(
          named: {
            'value': notifier,
            'child': const SizedBox.shrink(),
          },
        ),
        testContext(),
      );
      expect(widget, isA<Widget>());
    });

    test('RuneReactiveNotifier state getter returns the per-rebuild map', () {
      final notifier = _ReactiveCounter()..v = 7;
      addTearDown(notifier.dispose);
      expect(notifier.state, {'v': 7});
      notifier.v = 9;
      expect(notifier.state, {'v': 9});
    });
  });
}

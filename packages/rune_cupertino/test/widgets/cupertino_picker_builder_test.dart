import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';
import 'package:rune_cupertino/src/widgets/cupertino_picker_builder.dart';

import '../_helpers/test_context.dart';

void main() {
  group('CupertinoPickerBuilder', () {
    const b = CupertinoPickerBuilder();
    const children = <Widget>[Text('A'), Text('B'), Text('C')];

    test('typeName is "CupertinoPicker"', () {
      expect(b.typeName, 'CupertinoPicker');
    });

    test('requires itemExtent', () {
      expect(
        () => b.build(
          const ResolvedArguments(
            named: {'children': children},
          ),
          testContext(),
        ),
        throwsA(isA<ArgumentException>()),
      );
    });

    test('coerces num itemExtent to double and forwards children', () {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'itemExtent': 32,
            'children': children,
          },
        ),
        testContext(),
      ) as CupertinoPicker;
      expect(w.itemExtent, 32.0);
    });

    test('filters non-Widget entries from children, matching Column pattern',
        () {
      const mixed = <Object?>[Text('A'), 42, Text('B')];
      final w = b.build(
        const ResolvedArguments(
          named: {
            'itemExtent': 20.0,
            'children': mixed,
          },
        ),
        testContext(),
      ) as CupertinoPicker;
      expect(w.itemExtent, 20.0);
    });

    test('onSelectedItemChanged string dispatches with the new index', () {
      final events = RuneEventDispatcher();
      final captured = <List<Object?>>[];
      events.setCatchAllHandler((name, args) {
        if (name == 'picked') captured.add(args);
      });
      final w = b.build(
        const ResolvedArguments(
          named: {
            'itemExtent': 32.0,
            'children': children,
            'onSelectedItemChanged': 'picked',
          },
        ),
        testContext(events: events),
      ) as CupertinoPicker;
      w.onSelectedItemChanged!.call(2);
      expect(captured, [
        [2],
      ]);
    });

    test('scrollController is forwarded when supplied', () {
      final ctrl = FixedExtentScrollController(initialItem: 1);
      final w = b.build(
        ResolvedArguments(
          named: {
            'itemExtent': 32.0,
            'children': children,
            'scrollController': ctrl,
          },
        ),
        testContext(),
      ) as CupertinoPicker;
      expect(w.scrollController, same(ctrl));
    });

    test('optional styling params (magnification, useMagnifier) forward', () {
      final w = b.build(
        const ResolvedArguments(
          named: {
            'itemExtent': 32.0,
            'children': children,
            'magnification': 1.2,
            'useMagnifier': true,
            'squeeze': 1.5,
            'backgroundColor': Color(0xFF112233),
          },
        ),
        testContext(),
      ) as CupertinoPicker;
      expect(w.magnification, 1.2);
      expect(w.useMagnifier, isTrue);
      expect(w.squeeze, 1.5);
      expect(w.backgroundColor, const Color(0xFF112233));
    });
  });
}

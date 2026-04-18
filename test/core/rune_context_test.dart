import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_data_context.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/core/rune_context.dart';
import 'package:rune/src/registry/constant_registry.dart';
import 'package:rune/src/registry/value_registry.dart';
import 'package:rune/src/registry/widget_registry.dart';

void main() {
  group('RuneContext', () {
    test('all fields are exposed', () {
      final widgets = WidgetRegistry();
      final values = ValueRegistry();
      final data = RuneDataContext(const {'x': 1});
      final events = RuneEventDispatcher();
      final constants = ConstantRegistry();
      final ctx = RuneContext(
        widgets: widgets,
        values: values,
        data: data,
        events: events,
        constants: constants,
      );
      expect(ctx.widgets, same(widgets));
      expect(ctx.values, same(values));
      expect(ctx.data, same(data));
      expect(ctx.events, same(events));
      expect(ctx.constants, same(constants));
      expect(ctx.flutterContext, isNull);
    });

    test('copyWith replaces only provided fields', () {
      final ctx = RuneContext(
        widgets: WidgetRegistry(),
        values: ValueRegistry(),
        data: RuneDataContext.empty,
        events: RuneEventDispatcher(),
        constants: ConstantRegistry(),
      );
      final newData = RuneDataContext(const {'k': 'v'});
      final copy = ctx.copyWith(data: newData);
      expect(copy.data, same(newData));
      expect(copy.widgets, same(ctx.widgets));
      expect(copy.values, same(ctx.values));
      expect(copy.events, same(ctx.events));
      expect(copy.constants, same(ctx.constants));
    });

    test('copyWith with no args returns a context with the same fields', () {
      final ctx = RuneContext(
        widgets: WidgetRegistry(),
        values: ValueRegistry(),
        data: RuneDataContext.empty,
        events: RuneEventDispatcher(),
        constants: ConstantRegistry(),
      );
      final copy = ctx.copyWith();
      expect(copy.widgets, same(ctx.widgets));
      expect(copy.values, same(ctx.values));
      expect(copy.data, same(ctx.data));
      expect(copy.events, same(ctx.events));
      expect(copy.constants, same(ctx.constants));
      expect(copy.flutterContext, same(ctx.flutterContext));
    });

    testWidgets('flutterContext is retained when supplied', (tester) async {
      late BuildContext captured;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (ctx) {
              captured = ctx;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final runeCtx = RuneContext(
        widgets: WidgetRegistry(),
        values: ValueRegistry(),
        data: RuneDataContext.empty,
        events: RuneEventDispatcher(),
        constants: ConstantRegistry(),
        flutterContext: captured,
      );

      expect(runeCtx.flutterContext, same(captured));
    });

    test('constants field is required and exposed', () {
      final constants = ConstantRegistry();
      final ctx = RuneContext(
        widgets: WidgetRegistry(),
        values: ValueRegistry(),
        data: RuneDataContext.empty,
        events: RuneEventDispatcher(),
        constants: constants,
      );
      expect(ctx.constants, same(constants));
    });

    test('copyWith replaces constants only when provided', () {
      final originalConstants = ConstantRegistry();
      final newConstants = ConstantRegistry();
      final ctx = RuneContext(
        widgets: WidgetRegistry(),
        values: ValueRegistry(),
        data: RuneDataContext.empty,
        events: RuneEventDispatcher(),
        constants: originalConstants,
      );
      expect(ctx.copyWith().constants, same(originalConstants));
      expect(
        ctx.copyWith(constants: newConstants).constants,
        same(newConstants),
      );
    });
  });
}

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_data_context.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/core/rune_context.dart';
import 'package:rune/src/registry/value_registry.dart';
import 'package:rune/src/registry/widget_registry.dart';

void main() {
  group('RuneContext', () {
    test('all fields are exposed', () {
      final widgets = WidgetRegistry();
      final values = ValueRegistry();
      final data = RuneDataContext(const {'x': 1});
      final events = RuneEventDispatcher();
      final ctx = RuneContext(
        widgets: widgets,
        values: values,
        data: data,
        events: events,
      );
      expect(ctx.widgets, same(widgets));
      expect(ctx.values, same(values));
      expect(ctx.data, same(data));
      expect(ctx.events, same(events));
      expect(ctx.flutterContext, isNull);
    });

    test('copyWith replaces only provided fields', () {
      final ctx = RuneContext(
        widgets: WidgetRegistry(),
        values: ValueRegistry(),
        data: RuneDataContext.empty,
        events: RuneEventDispatcher(),
      );
      final newData = RuneDataContext(const {'k': 'v'});
      final copy = ctx.copyWith(data: newData);
      expect(copy.data, same(newData));
      expect(copy.widgets, same(ctx.widgets));
      expect(copy.values, same(ctx.values));
      expect(copy.events, same(ctx.events));
    });

    test('copyWith with no args returns a context with the same fields', () {
      final ctx = RuneContext(
        widgets: WidgetRegistry(),
        values: ValueRegistry(),
        data: RuneDataContext.empty,
        events: RuneEventDispatcher(),
      );
      final copy = ctx.copyWith();
      expect(copy.widgets, same(ctx.widgets));
      expect(copy.values, same(ctx.values));
      expect(copy.data, same(ctx.data));
      expect(copy.events, same(ctx.events));
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
        flutterContext: captured,
      );

      expect(runeCtx.flutterContext, same(captured));
    });
  });
}

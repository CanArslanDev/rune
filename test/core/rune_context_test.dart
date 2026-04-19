import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/src/binding/rune_data_context.dart';
import 'package:rune/src/binding/rune_event_dispatcher.dart';
import 'package:rune/src/core/rune_context.dart';
import 'package:rune/src/registry/constant_registry.dart';
import 'package:rune/src/registry/extension_registry.dart';
import 'package:rune/src/registry/value_registry.dart';
import 'package:rune/src/registry/widget_registry.dart';

import '../_helpers/test_context.dart';

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
        extensions: ExtensionRegistry(),
        source: '',
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
        extensions: ExtensionRegistry(),
        source: '',
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
        extensions: ExtensionRegistry(),
        source: '',
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
        extensions: ExtensionRegistry(),
        source: '',
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
        extensions: ExtensionRegistry(),
        source: '',
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
        extensions: ExtensionRegistry(),
        source: '',
      );
      expect(ctx.copyWith().constants, same(originalConstants));
      expect(
        ctx.copyWith(constants: newConstants).constants,
        same(newConstants),
      );
    });

    test('extensions field is required and exposed', () {
      final extensions = ExtensionRegistry();
      final ctx = RuneContext(
        widgets: WidgetRegistry(),
        values: ValueRegistry(),
        data: RuneDataContext.empty,
        events: RuneEventDispatcher(),
        constants: ConstantRegistry(),
        extensions: extensions,
        source: '',
      );
      expect(ctx.extensions, same(extensions));
    });

    test('copyWith replaces extensions only when provided', () {
      final original = ExtensionRegistry();
      final replacement = ExtensionRegistry();
      final ctx = RuneContext(
        widgets: WidgetRegistry(),
        values: ValueRegistry(),
        data: RuneDataContext.empty,
        events: RuneEventDispatcher(),
        constants: ConstantRegistry(),
        extensions: original,
        source: '',
      );
      expect(ctx.copyWith().extensions, same(original));
      expect(
        ctx.copyWith(extensions: replacement).extensions,
        same(replacement),
      );
    });
  });

  group('RuneContext.source field', () {
    test('source round-trips through constructor', () {
      final ctx = RuneContext(
        widgets: WidgetRegistry(),
        values: ValueRegistry(),
        data: RuneDataContext.empty,
        events: RuneEventDispatcher(),
        constants: ConstantRegistry(),
        extensions: ExtensionRegistry(),
        source: 'Text("hi")',
      );
      expect(ctx.source, 'Text("hi")');
    });

    test('copyWith(source: ...) replaces it, leaves other fields intact', () {
      final ctx = RuneContext(
        widgets: WidgetRegistry(),
        values: ValueRegistry(),
        data: RuneDataContext.empty,
        events: RuneEventDispatcher(),
        constants: ConstantRegistry(),
        extensions: ExtensionRegistry(),
        source: 'a',
      );
      final copy = ctx.copyWith(source: 'b');
      expect(copy.source, 'b');
      expect(copy.widgets, same(ctx.widgets));
      expect(copy.values, same(ctx.values));
      expect(copy.data, same(ctx.data));
      expect(copy.events, same(ctx.events));
      expect(copy.constants, same(ctx.constants));
      expect(copy.extensions, same(ctx.extensions));
      expect(copy.flutterContext, same(ctx.flutterContext));
    });

    test('copyWith() without source preserves existing source', () {
      final ctx = RuneContext(
        widgets: WidgetRegistry(),
        values: ValueRegistry(),
        data: RuneDataContext.empty,
        events: RuneEventDispatcher(),
        constants: ConstantRegistry(),
        extensions: ExtensionRegistry(),
        source: 'original',
      );
      final copy = ctx.copyWith(
        data: RuneDataContext(const {'k': 'v'}),
      );
      expect(copy.source, 'original');
    });

    test('empty source is a valid value', () {
      final ctx = RuneContext(
        widgets: WidgetRegistry(),
        values: ValueRegistry(),
        data: RuneDataContext.empty,
        events: RuneEventDispatcher(),
        constants: ConstantRegistry(),
        extensions: ExtensionRegistry(),
        source: '',
      );
      expect(ctx.source, '');
      expect(ctx.source.isEmpty, isTrue);
    });

    test('testRuneContext() default source is empty string', () {
      final ctx = testContext();
      expect(ctx.source, '');
    });

    test('testRuneContext(source: ...) threads through', () {
      final ctx = testContext(source: 'Column()');
      expect(ctx.source, 'Column()');
    });
  });
}

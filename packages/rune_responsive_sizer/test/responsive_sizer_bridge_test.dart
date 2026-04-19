import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rune/rune.dart';
import 'package:rune_responsive_sizer/rune_responsive_sizer.dart';

Widget _harness({
  required RuneConfig config,
  required String source,
  Size screenSize = const Size(400, 800),
}) {
  return MediaQuery(
    data: MediaQueryData(size: screenSize),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: RuneView(source: source, config: config),
    ),
  );
}

void main() {
  group('ResponsiveSizerBridge', () {
    test('registerInto adds four extension handlers', () {
      final config = RuneConfig()..withBridges(const [ResponsiveSizerBridge()]);
      expect(config.extensions.contains('w'), isTrue);
      expect(config.extensions.contains('h'), isTrue);
      expect(config.extensions.contains('sp'), isTrue);
      expect(config.extensions.contains('dm'), isTrue);
    });

    testWidgets('50.w returns 50% of screen width', (tester) async {
      final config = RuneConfig.defaults()
          .withBridges(const [ResponsiveSizerBridge()]);
      await tester.pumpWidget(
        _harness(
          config: config,
          source: "SizedBox(width: 50.w, child: Text('x'))",
        ),
      );
      final box = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(box.width, 200.0);
    });

    testWidgets('25.h returns 25% of screen height', (tester) async {
      final config = RuneConfig.defaults()
          .withBridges(const [ResponsiveSizerBridge()]);
      await tester.pumpWidget(
        _harness(
          config: config,
          source: "SizedBox(height: 25.h, child: Text('x'))",
        ),
      );
      final box = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(box.height, 200.0);
    });

    testWidgets('10.dm returns 10% of min(width, height)', (tester) async {
      final config = RuneConfig.defaults()
          .withBridges(const [ResponsiveSizerBridge()]);
      await tester.pumpWidget(
        _harness(
          config: config,
          source: "SizedBox(width: 10.dm, child: Text('x'))",
          screenSize: const Size(500, 300),
        ),
      );
      final box = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(box.width, 30.0);
    });

    testWidgets('16.sp respects MediaQuery.textScaler', (tester) async {
      final config = RuneConfig.defaults()
          .withBridges(const [ResponsiveSizerBridge()]);
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(400, 800),
            textScaler: TextScaler.linear(1.5),
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: RuneView(
              source: "Text('x', style: TextStyle(fontSize: 16.sp))",
              config: config,
            ),
          ),
        ),
      );
      final text = tester.widget<Text>(find.text('x'));
      expect(text.style?.fontSize, 24.0);
    });

    test('non-num target throws ArgumentError', () {
      final config = RuneConfig()
        ..withBridges(const [ResponsiveSizerBridge()]);
      final ctx = RuneContext(
        widgets: config.widgets,
        values: config.values,
        data: RuneDataContext.empty,
        events: RuneEventDispatcher(),
        constants: config.constants,
        extensions: config.extensions,
        components: ComponentRegistry(),
        source: '',
      );
      expect(
        () => config.extensions.require(
          'w',
          'not-a-number',
          ctx,
          source: 'x.w',
        ),
        throwsArgumentError,
      );
    });

    test('null flutterContext throws StateError', () {
      final config = RuneConfig()
        ..withBridges(const [ResponsiveSizerBridge()]);
      final ctx = RuneContext(
        widgets: config.widgets,
        values: config.values,
        data: RuneDataContext.empty,
        events: RuneEventDispatcher(),
        constants: config.constants,
        extensions: config.extensions,
        components: ComponentRegistry(),
        source: '',
      );
      expect(
        () => config.extensions.require('w', 42, ctx, source: 'x.w'),
        throwsA(isA<StateError>()),
      );
    });
  });
}

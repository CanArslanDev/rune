/// Test-ergonomics helpers for Rune source.
///
/// Two things you would write by hand every time without this
/// package:
///
/// - `pumpRuneView` wraps `tester.pumpWidget` around a
///   `MaterialApp` + `RuneView` with sensible defaults. Most
///   widget tests that render source strings through `RuneView`
///   end up writing the same 10-line harness; this trims it to
///   one call.
/// - `expectRuneRenders` is a one-line assertion: pump the
///   source, check that the given finder-matcher pair matches.
///
/// ```dart
/// testWidgets('greeting renders', (tester) async {
///   await expectRuneRenders(
///     tester,
///     "Text('Hello, $name!')",
///     data: const {'name': 'Ali'},
///     find.text('Hello, Ali!'),
///     findsOneWidget,
///   );
/// });
/// ```
library rune_test;

export 'src/helpers.dart'
    show
        defaultRuneTestConfig,
        expectRuneRenders,
        pumpRuneView;

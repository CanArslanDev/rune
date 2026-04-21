/// Validation helpers for Rune source strings.
///
/// The main use case is test-time safety: instead of finding out at
/// runtime that `Icons.shoping_cart` is a typo or that
/// `CupertinoButton` was used without applying `CupertinoBridge`,
/// run `validateRuneSource` in a unit test and the issues surface
/// as test failures before any user sees them.
///
/// ```dart
/// import 'package:flutter_test/flutter_test.dart';
/// import 'package:rune/rune.dart';
/// import 'package:rune_lint/rune_lint.dart';
///
/// void main() {
///   test('home.rune is valid', () {
///     final issues = validateRuneSource(
///       homeSource,
///       RuneConfig.defaults(),
///     );
///     expect(issues, isEmpty, reason: 'Found: $issues');
///   });
/// }
/// ```
///
/// Or use the `expectValidRuneSource` convenience:
///
/// ```dart
/// expectValidRuneSource(homeSource, RuneConfig.defaults());
/// ```
library rune_lint;

export 'src/rune_lint_issue.dart'
    show RuneLintIssue, RuneLintIssueKind;
export 'src/rune_lint_matchers.dart' show expectValidRuneSource;
export 'src/rune_source_validator.dart' show validateRuneSource;

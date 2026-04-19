import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds a `DateTime` from Dart's positional
/// `DateTime(year, [month, day, hour, minute, second, millisecond,
/// microsecond])` constructor.
///
/// Only positional arguments are accepted: the year slot (index 0) is
/// required; month and day default to `1`; hour, minute, second,
/// millisecond, microsecond default to `0`. Matches Dart's built-in
/// `DateTime` API exactly.
///
/// Registered primarily so Rune source can construct bounds for the
/// v1.4.0 `showDatePicker(...)` imperative bridge.
final class DateTimeBuilder implements RuneValueBuilder {
  /// Const constructor - the builder is stateless.
  const DateTimeBuilder();

  @override
  String get typeName => 'DateTime';

  @override
  String? get constructorName => null;

  @override
  DateTime build(ResolvedArguments args, RuneContext ctx) {
    final year = args.requirePositional<int>(0, source: 'DateTime');
    final month = args.positionalAt<int>(1) ?? 1;
    final day = args.positionalAt<int>(2) ?? 1;
    final hour = args.positionalAt<int>(3) ?? 0;
    final minute = args.positionalAt<int>(4) ?? 0;
    final second = args.positionalAt<int>(5) ?? 0;
    final millisecond = args.positionalAt<int>(6) ?? 0;
    final microsecond = args.positionalAt<int>(7) ?? 0;
    return DateTime(
      year,
      month,
      day,
      hour,
      minute,
      second,
      millisecond,
      microsecond,
    );
  }
}

import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds a [Duration] from Dart's default named-arg constructor.
///
/// Supports every field Dart's own `Duration({days, hours, minutes,
/// seconds, milliseconds, microseconds})` accepts; each defaults to 0,
/// so omitting every argument yields [Duration.zero]. Values must be
/// `int` — matching Dart's `Duration` API.
final class DurationBuilder implements RuneValueBuilder {
  /// Const constructor — the builder is stateless.
  const DurationBuilder();

  @override
  String get typeName => 'Duration';

  @override
  String? get constructorName => null;

  @override
  Duration build(ResolvedArguments args, RuneContext ctx) {
    return Duration(
      days: args.getOr<int>('days', 0),
      hours: args.getOr<int>('hours', 0),
      minutes: args.getOr<int>('minutes', 0),
      seconds: args.getOr<int>('seconds', 0),
      milliseconds: args.getOr<int>('milliseconds', 0),
      microseconds: args.getOr<int>('microseconds', 0),
    );
  }
}

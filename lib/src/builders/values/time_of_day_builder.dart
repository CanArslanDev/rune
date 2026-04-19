import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds a [TimeOfDay] from the named `TimeOfDay(hour:, minute:)`
/// constructor.
///
/// Both `hour` and `minute` are required (Dart's [TimeOfDay] constructor
/// has no defaults) and must be `int`. Registered primarily so Rune
/// source can construct the `initialTime` argument for the v1.4.0
/// `showTimePicker(...)` imperative bridge.
final class TimeOfDayBuilder implements RuneValueBuilder {
  /// Const constructor - the builder is stateless.
  const TimeOfDayBuilder();

  @override
  String get typeName => 'TimeOfDay';

  @override
  String? get constructorName => null;

  @override
  TimeOfDay build(ResolvedArguments args, RuneContext ctx) {
    return TimeOfDay(
      hour: args.require<int>('hour', source: 'TimeOfDay'),
      minute: args.require<int>('minute', source: 'TimeOfDay'),
    );
  }
}

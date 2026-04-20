// CI-pinned Flutter 3.24.0 uses `activeColor:` on CupertinoSwitch;
// it was renamed to `activeTrackColor:` after 3.24.0-0.2.pre. Keeping
// `activeColor:` compiles on both the pinned CI floor and modern dev
// Flutter (with a tolerable deprecation notice).
// ignore_for_file: deprecated_member_use
import 'package:flutter/cupertino.dart';
import 'package:rune/rune.dart';

/// Builds [CupertinoSwitch] with two-way value binding.
///
/// Source arguments:
/// - `value` (`bool`) - current on/off state. Defaults to `false`.
/// - `onChanged` (`String` or closure) - dispatched with the new `bool`
///   on toggle. A missing `onChanged` leaves the switch disabled.
/// - `activeColor` ([Color]?) - track color when on.
/// - `thumbColor` ([Color]?) - thumb color override.
final class CupertinoSwitchBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const CupertinoSwitchBuilder();

  @override
  String get typeName => 'CupertinoSwitch';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return CupertinoSwitch(
      value: args.getOr<bool>('value', false),
      onChanged: valueEventCallback<bool>(
        args.named['onChanged'],
        ctx.events,
      ),
      activeColor: args.get<Color>('activeColor'),
      thumbColor: args.get<Color>('thumbColor'),
    );
  }
}

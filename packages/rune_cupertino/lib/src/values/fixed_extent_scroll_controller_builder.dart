import 'package:flutter/cupertino.dart';
import 'package:rune/rune.dart';

/// Builds [FixedExtentScrollController], the [ScrollController] subtype
/// required by [CupertinoPicker] to programmatically read or drive the
/// currently selected item index.
///
/// Supported named arguments (all optional):
/// - `initialItem` (`int`) - index of the selected item on first mount.
///   Defaults to `0`.
///
/// The returned controller is owned by the caller. Host apps that embed
/// the controller in a stateful slot (e.g. `StatefulBuilder`'s `initial`
/// map) are responsible for disposing it. Re-rendering a source that
/// constructs a fresh controller on every pass leaks controllers, so
/// usually consumers bind the controller once via initial-map state and
/// pass a reference through.
final class FixedExtentScrollControllerBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const FixedExtentScrollControllerBuilder();

  @override
  String get typeName => 'FixedExtentScrollController';

  @override
  String? get constructorName => null;

  @override
  FixedExtentScrollController build(ResolvedArguments args, RuneContext ctx) {
    return FixedExtentScrollController(
      initialItem: args.getOr<int>('initialItem', 0),
    );
  }
}

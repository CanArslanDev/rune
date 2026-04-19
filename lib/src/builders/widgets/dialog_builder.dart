import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds Material [Dialog] - the low-level modal surface used directly
/// when consumers want full layout control over the dialog body.
/// Higher-level helpers [AlertDialog] and [SimpleDialog] should be
/// preferred for typical prompts; [Dialog] is available when the design
/// demands a custom body.
///
/// Supported named arguments:
/// - `child` ([Widget]?) - the body content.
/// - `backgroundColor` ([Color]?).
/// - `elevation` ([num]? coerced to double).
/// - `insetPadding` ([EdgeInsets]?). When omitted, falls back to
///   Flutter's default.
/// - `clipBehavior` ([Clip]?). Omitted defaults to [Clip.none].
final class DialogBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const DialogBuilder();

  @override
  String get typeName => 'Dialog';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return Dialog(
      backgroundColor: args.get<Color>('backgroundColor'),
      elevation: args.get<num>('elevation')?.toDouble(),
      insetPadding: args.get<EdgeInsets>('insetPadding'),
      clipBehavior: args.getOr<Clip>('clipBehavior', Clip.none),
      child: args.get<Widget>('child'),
    );
  }
}

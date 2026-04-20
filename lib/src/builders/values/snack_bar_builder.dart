import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds Material [SnackBar] as a value.
///
/// SnackBars are surfaced imperatively via the `showSnackBar(...)` bridge
/// (which routes through `ScaffoldMessenger.of(context).showSnackBar`),
/// so they live in the value registry rather than the widget registry:
/// source expressions like `showSnackBar(SnackBar(content: Text('hi')))`
/// depend on `SnackBar(...)` resolving to a Dart [SnackBar] instance, not
/// to a [Widget] placed into a widget tree.
///
/// Supported named arguments:
/// - `content` ([Widget], required).
/// - `backgroundColor` ([Color]?).
/// - `duration` ([Duration]?). Defaults to Flutter's 4-second default.
/// - `behavior` ([SnackBarBehavior]?).
/// - `elevation` ([num]? coerced to double).
/// - `margin` ([EdgeInsetsGeometry]?).
/// - `padding` ([EdgeInsetsGeometry]?).
/// - `showCloseIcon` ([bool]?).
///
/// - `action` ([SnackBarAction]?) - wired in v1.12.0.
final class SnackBarBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const SnackBarBuilder();

  @override
  String get typeName => 'SnackBar';

  @override
  String? get constructorName => null;

  @override
  SnackBar build(ResolvedArguments args, RuneContext ctx) {
    final content = args.require<Widget>('content', source: 'SnackBar');
    return SnackBar(
      content: content,
      backgroundColor: args.get<Color>('backgroundColor'),
      duration: args.getOr<Duration>(
        'duration',
        const Duration(milliseconds: 4000),
      ),
      behavior: args.get<SnackBarBehavior>('behavior'),
      elevation: args.get<num>('elevation')?.toDouble(),
      margin: args.get<EdgeInsetsGeometry>('margin'),
      padding: args.get<EdgeInsetsGeometry>('padding'),
      showCloseIcon: args.get<bool>('showCloseIcon'),
      action: args.get<SnackBarAction>('action'),
    );
  }
}

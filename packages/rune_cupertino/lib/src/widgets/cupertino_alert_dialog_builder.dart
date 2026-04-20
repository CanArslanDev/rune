import 'package:flutter/cupertino.dart';
import 'package:rune/rune.dart';

/// Builds [CupertinoAlertDialog], an iOS-style modal dialog typically
/// shown via an imperative `showCupertinoDialog(...)` bridge.
///
/// Supported named arguments:
/// - `title` ([Widget]?) - large-font title.
/// - `content` ([Widget]?) - body content.
/// - `actions` (`List<Widget>?`) - action buttons (typically
///   [CupertinoDialogAction]). Non-[Widget] entries are silently
///   dropped, matching the Column/Row children-filter convention.
final class CupertinoAlertDialogBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const CupertinoAlertDialogBuilder();

  @override
  String get typeName => 'CupertinoAlertDialog';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final rawActions = args.get<List<Object?>>('actions');
    final actions =
        rawActions?.whereType<Widget>().toList(growable: false) ??
            const <Widget>[];
    return CupertinoAlertDialog(
      title: args.get<Widget>('title'),
      content: args.get<Widget>('content'),
      actions: actions,
    );
  }
}

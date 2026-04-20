import 'package:flutter/cupertino.dart';
import 'package:rune/rune.dart';

/// Builds [CupertinoNavigationBar], the iOS-style top chrome typically
/// placed in a [CupertinoPageScaffold]'s `navigationBar` slot.
///
/// Supported named arguments:
/// - `middle` ([Widget]?) - centered title widget.
/// - `leading` ([Widget]?) - leading content. Flutter's own
///   `automaticallyImplyLeading` handles the back button by default.
/// - `trailing` ([Widget]?) - trailing content (icons, actions).
/// - `backgroundColor` ([Color]?) - bar background.
/// - `previousPageTitle` (`String?`) - label for the inferred back
///   button when the host pushes this scaffold onto a
///   [CupertinoPageRoute].
final class CupertinoNavigationBarBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const CupertinoNavigationBarBuilder();

  @override
  String get typeName => 'CupertinoNavigationBar';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return CupertinoNavigationBar(
      middle: args.get<Widget>('middle'),
      leading: args.get<Widget>('leading'),
      trailing: args.get<Widget>('trailing'),
      backgroundColor: args.get<Color>('backgroundColor'),
      previousPageTitle: args.get<String>('previousPageTitle'),
    );
  }
}

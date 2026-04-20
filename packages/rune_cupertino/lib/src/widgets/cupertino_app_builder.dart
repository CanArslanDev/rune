import 'package:flutter/cupertino.dart';
import 'package:rune/rune.dart';

/// Builds [CupertinoApp], the top-level iOS-style app surface.
///
/// Supported named arguments:
/// - `home` ([Widget]?) - root widget mounted when no route table is
///   in use.
/// - `theme` ([CupertinoThemeData]?) - app-wide theme.
/// - `title` (`String`) - defaults to empty string.
/// - `debugShowCheckedModeBanner` (`bool`) - defaults to `true`,
///   matching Flutter's own default.
/// - `color` ([Color]?) - primary OS-level color (affects task switcher
///   chrome on some platforms).
final class CupertinoAppBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const CupertinoAppBuilder();

  @override
  String get typeName => 'CupertinoApp';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    return CupertinoApp(
      home: args.get<Widget>('home'),
      theme: args.get<CupertinoThemeData>('theme'),
      title: args.getOr<String>('title', ''),
      color: args.get<Color>('color'),
      debugShowCheckedModeBanner:
          args.getOr<bool>('debugShowCheckedModeBanner', true),
    );
  }
}

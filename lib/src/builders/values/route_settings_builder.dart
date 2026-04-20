import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds a [RouteSettings] value.
///
/// [RouteSettings] is how navigation primitives attach a logical name and
/// optional payload to a route. Rune source typically supplies it via
/// `MaterialPageRoute(settings: RouteSettings(name: '/detail'))` or through
/// `Navigator.pushNamed` (which constructs the settings internally).
///
/// Supported named arguments:
/// - `name` ([String]?, optional).
/// - `arguments` ([Object]?, optional; any value that would be legal as
///   `RouteSettings.arguments`).
final class RouteSettingsBuilder implements RuneValueBuilder {
  /// Const constructor. The builder is stateless.
  const RouteSettingsBuilder();

  @override
  String get typeName => 'RouteSettings';

  @override
  String? get constructorName => null;

  @override
  RouteSettings build(ResolvedArguments args, RuneContext ctx) {
    return RouteSettings(
      name: args.get<String>('name'),
      arguments: args.named['arguments'],
    );
  }
}

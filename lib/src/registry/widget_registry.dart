import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/registry/registry.dart';

/// A [Registry] specialized for [RuneWidgetBuilder]s.
final class WidgetRegistry extends Registry<RuneWidgetBuilder> {
  /// Creates an empty [WidgetRegistry].
  WidgetRegistry();

  /// Registers [builder] using its own [RuneBuilder.typeName] as the key.
  ///
  /// Prefer this over [register] to keep registrations free of duplicated
  /// string keys that could drift from the builder's declared type name.
  void registerBuilder(RuneWidgetBuilder builder) {
    register(builder.typeName, builder);
  }
}

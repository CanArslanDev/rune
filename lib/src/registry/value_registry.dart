import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/registry/registry.dart';

/// A [Registry] specialized for [RuneValueBuilder]s.
///
/// Lookup keys follow the convention:
///   - `"TypeName"` for default-constructor builders, and
///   - `"TypeName.constructorName"` for named-constructor builders.
///
/// This mirrors the key that `InvocationResolver` composes from the parsed
/// AST so direct `find` / `findValue` calls align.
final class ValueRegistry extends Registry<RuneValueBuilder> {
  /// Creates an empty [ValueRegistry].
  ValueRegistry();

  /// Registers [builder] under the composed key described in the class
  /// docs.
  void registerBuilder(RuneValueBuilder builder) {
    register(_keyOf(builder.typeName, builder.constructorName), builder);
  }

  /// Convenience accessor that composes the same key scheme as
  /// [registerBuilder].
  RuneValueBuilder? findValue(String typeName, {String? constructorName}) {
    return find(_keyOf(typeName, constructorName));
  }

  static String _keyOf(String typeName, String? constructorName) {
    return constructorName == null ? typeName : '$typeName.$constructorName';
  }
}

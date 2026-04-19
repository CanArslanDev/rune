import 'package:flutter/widgets.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_component.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds the root of a component-declaring source expression.
///
/// `RuneCompose(components: [...], root: <Widget>)` ties a list of
/// declared [RuneComponent]s to the widget tree that uses them. The
/// argument resolver walks `components` first (each entry is a
/// `RuneComponent(...)` value-builder invocation that side-effect-
/// registers in [RuneContext.components]) and then resolves `root`,
/// by which point the registry is populated.
///
/// The builder itself returns the `root` argument. Receiving the
/// already-resolved
/// `components` list lets this builder assert every entry is actually
/// a [RuneComponent]; it does NOT re-register (registration happened
/// during argument resolution).
///
/// ```
/// RuneCompose(
///   components: [
///     RuneComponent(name: 'Greeting', params: ['who'],
///       body: (who) => Text('Hello, ' + who)),
///   ],
///   root: Greeting(who: 'world'),
/// )
/// ```
final class RuneComposeBuilder implements RuneWidgetBuilder {
  /// Const constructor. The builder is stateless.
  const RuneComposeBuilder();

  @override
  String get typeName => 'RuneCompose';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final rawComponents = args.named['components'];
    if (rawComponents == null) {
      throw const ArgumentException(
        'RuneCompose',
        'Missing required argument "components"',
      );
    }
    if (rawComponents is! List<Object?>) {
      throw ArgumentException(
        'RuneCompose',
        '`components` must be a List of RuneComponent values; got '
        '${rawComponents.runtimeType}',
      );
    }
    for (final entry in rawComponents) {
      if (entry is! RuneComponent) {
        throw ArgumentException(
          'RuneCompose',
          '`components` entries must be RuneComponent values; got '
          '${entry.runtimeType}',
        );
      }
    }
    final root = args.named['root'];
    if (root == null) {
      throw const ArgumentException(
        'RuneCompose',
        'Missing required argument "root"',
      );
    }
    if (root is! Widget) {
      throw ArgumentException(
        'RuneCompose',
        '`root` must be a Widget; got ${root.runtimeType}',
      );
    }
    return root;
  }
}

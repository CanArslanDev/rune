import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_component.dart';
import 'package:rune/src/resolver/rune_closure.dart';

/// Builds a [RuneComponent] from a resolved `RuneComponent(...)`
/// invocation's arguments.
///
/// Lives in the `builders/` root rather than in
/// `builders/values/rune_component_builder.dart` because the
/// architecture invariant forbids `builders/values/` from importing
/// `src/resolver/`, and components wrap a [RuneClosure] body. The
/// single permitted resolver import from `builders/` root is
/// [RuneClosure] itself (see `event_callback.dart` and
/// `stateful_builder_helpers.dart` for the precedent).
///
/// Validates:
///   * `name` is a non-empty String;
///   * `params` is a `List<Object?>` of Strings (the declared parameter
///     names);
///   * `body` is a [RuneClosure] whose arity matches `params.length`.
///
/// Throws [ArgumentException] on any violation.
RuneComponent buildRuneComponent({
  required Object? rawName,
  required Object? rawParams,
  required Object? rawBody,
}) {
  if (rawName is! String) {
    throw ArgumentException(
      'RuneComponent',
      '`name` must be a String; got ${rawName.runtimeType}',
    );
  }
  if (rawName.isEmpty) {
    throw const ArgumentException(
      'RuneComponent',
      '`name` must be a non-empty String',
    );
  }
  if (rawParams is! List<Object?>) {
    throw ArgumentException(
      'RuneComponent',
      '`params` must be a List of parameter name strings; got '
      '${rawParams.runtimeType}',
    );
  }
  final parameterNames = <String>[];
  for (final p in rawParams) {
    if (p is! String) {
      throw ArgumentException(
        'RuneComponent',
        '`params` entries must be Strings; got ${p.runtimeType}',
      );
    }
    parameterNames.add(p);
  }
  if (rawBody is! RuneClosure) {
    throw ArgumentException(
      'RuneComponent',
      '`body` must be a closure; got ${rawBody.runtimeType}',
    );
  }
  if (rawBody.parameterNames.length != parameterNames.length) {
    throw ArgumentException(
      'RuneComponent',
      '`body` closure arity (${rawBody.parameterNames.length}) does '
      'not match declared `params` length (${parameterNames.length})',
    );
  }
  return RuneComponent(
    name: rawName,
    parameterNames: parameterNames,
    body: rawBody.call,
  );
}

import 'package:analyzer/dart/ast/ast.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_component.dart';
import 'package:rune/src/core/rune_context.dart';
import 'package:rune/src/core/source_span.dart';
import 'package:rune/src/resolver/builtin_members.dart';
import 'package:rune/src/resolver/expression_resolver.dart';
import 'package:rune/src/resolver/rune_closure.dart';

/// Resolves constructor-call expressions — both bare `Text('hi')` shape
/// (parses as [MethodInvocation]) and explicit `new Text('hi')` shape
/// (parses as [InstanceCreationExpression]) — by looking up the matching
/// widget or value builder in the context's registries.
///
/// Widget registry takes precedence over value registry on name collision;
/// this keeps widget authoring ergonomic when a third-party bridge package
/// happens to ship a same-named value builder.
final class InvocationResolver implements InvocationResolverContract {
  /// Constructs an [InvocationResolver] that delegates argument resolution
  /// back to [ExpressionResolver]. The expression resolver must already
  /// exist — call [ExpressionResolver.bind] on it immediately after
  /// constructing both.
  InvocationResolver(this._expr);

  final ExpressionResolver _expr;

  @override
  Object? resolveInvocation(Expression node, RuneContext ctx) {
    return switch (node) {
      MethodInvocation() => _resolveMethodInvocation(node, ctx),
      InstanceCreationExpression() => _resolveInstanceCreation(node, ctx),
      _ => throw ResolveException(
          node.toSource(),
          'Not an invocation expression: ${node.runtimeType}',
          location:
              SourceSpan.fromAstOffset(ctx.source, node.offset, node.length),
        ),
    };
  }

  /// Dispatches a [MethodInvocation] to either a registered builder
  /// (`Text('hi')`, `EdgeInsets.all(16)`) or a whitelisted runtime-value
  /// method (`text.toUpperCase()`, `items[0].contains('a')`).
  ///
  /// Dispatch order:
  ///
  /// - `target == null` (bare `Text('hi')`): look up `methodName` as a
  ///   widget/value builder. Unregistered → [UnregisteredBuilderException].
  /// - `target is SimpleIdentifier`: first look up `target.name` as a
  ///   widget or value builder (`EdgeInsets.all(16)` shape); only if
  ///   neither registry holds that name do we fall through to runtime
  ///   method dispatch. This preserves every existing builder-call
  ///   behaviour.
  /// - any other target shape (`PropertyAccess`, `IndexExpression`,
  ///   `ParenthesizedExpression`, chained `MethodInvocation`, etc.): go
  ///   straight to runtime method dispatch on the resolved target.
  ///
  /// Runtime method dispatch resolves the target via the expression
  /// resolver — any [BindingException] for an absent data identifier
  /// bubbles naturally, which is the correct diagnostic for
  /// `someThing.foo()` where `someThing` is neither a builder nor a
  /// data key.
  Object? _resolveMethodInvocation(MethodInvocation node, RuneContext ctx) {
    final target = node.target;

    if (target == null) {
      // Flutter-idiomatic `setState(() { ... })` sugar. Phase C mutations
      // already trigger rebuilds via RuneState.onMutation, so the wrapper
      // is semantically a passthrough; its purpose is to let source read
      // naturally. Handle it before the registry lookup so a host-
      // registered `setState` builder cannot shadow the keyword.
      if (node.methodName.name == 'setState') {
        return _resolveSetState(node, ctx);
      }
      // Bare `Text('hi')`.
      return _dispatch(
        typeName: node.methodName.name,
        constructorName: null,
        argumentList: node.argumentList,
        ctx: ctx,
        source: node.toSource(),
        location:
            SourceSpan.fromAstOffset(ctx.source, node.offset, node.length),
      );
    }

    if (target is SimpleIdentifier) {
      // Either `EdgeInsets.all(16)` (builder) or `text.toUpperCase()`
      // (runtime method on a data identifier). Builder registries win.
      final typeName = target.name;
      final constructorName = node.methodName.name;
      // Phase F: a source-declared component with the same name as
      // `typeName` takes priority. Named-constructor shape is invalid
      // on a component call, so we raise ResolveException here (a
      // targeted diagnostic beats the silent fallthrough to runtime
      // method dispatch that would otherwise happen).
      final component = ctx.components.find(typeName);
      if (component != null) {
        throw ResolveException(
          node.toSource(),
          'Component $typeName does not accept a named constructor '
          '(got $typeName.$constructorName)',
          location:
              SourceSpan.fromAstOffset(ctx.source, node.offset, node.length),
        );
      }
      final widgetBuilder = ctx.widgets.find(typeName);
      if (widgetBuilder != null) {
        final args = _resolveArguments(node.argumentList, ctx);
        return _runBuilder(
          () => widgetBuilder.build(args, ctx),
          invocationLocation:
              SourceSpan.fromAstOffset(ctx.source, node.offset, node.length),
        );
      }
      final valueBuilder = ctx.values.findValue(
        typeName,
        constructorName: constructorName,
      );
      if (valueBuilder != null) {
        final args = _resolveArguments(node.argumentList, ctx);
        return _runBuilder(
          () => valueBuilder.build(args, ctx),
          invocationLocation:
              SourceSpan.fromAstOffset(ctx.source, node.offset, node.length),
        );
      }
      // Neither widget nor value builder — fall through to runtime
      // method dispatch on the resolved identifier.
      return _dispatchRuntimeMethod(node: node, ctx: ctx);
    }

    // Any other expression target — PropertyAccess, IndexExpression,
    // ParenthesizedExpression, chained MethodInvocation, etc. — goes
    // directly to runtime method dispatch.
    return _dispatchRuntimeMethod(node: node, ctx: ctx);
  }

  /// Resolves the Flutter-idiomatic `setState(() { ... })` sugar.
  ///
  /// Because Phase C state mutations already schedule a rebuild via
  /// `RuneState.onMutation`, the wrapper is semantically a passthrough:
  /// it evaluates the single no-arg closure argument and returns its
  /// result. It exists to let source code read like standard Flutter
  /// (`setState(() { state.counter = state.counter + 1; })`) and to
  /// group related mutations visually.
  ///
  /// Validates:
  ///   * exactly one argument;
  ///   * the argument resolves to a [RuneClosure];
  ///   * the closure declares no parameters.
  ///
  /// Any violation raises [ResolveException] with a span pointing at
  /// the `setState(...)` call.
  Object? _resolveSetState(MethodInvocation node, RuneContext ctx) {
    final args = node.argumentList.arguments;
    final loc = SourceSpan.fromAstOffset(ctx.source, node.offset, node.length);
    if (args.length != 1) {
      throw ResolveException(
        node.toSource(),
        'setState expects exactly one closure argument, got ${args.length}',
        location: loc,
      );
    }
    final arg = args.single;
    if (arg is NamedExpression) {
      throw ResolveException(
        node.toSource(),
        'setState expects a positional closure argument, '
        'got a named argument "${arg.name.label.name}"',
        location: loc,
      );
    }
    final resolved = _expr.resolve(arg, ctx);
    if (resolved is! RuneClosure) {
      throw ResolveException(
        node.toSource(),
        'setState expects a closure; got ${resolved.runtimeType}',
        location: loc,
      );
    }
    if (resolved.parameterNames.isNotEmpty) {
      throw ResolveException(
        node.toSource(),
        'setState closure must take no parameters; '
        'got ${resolved.parameterNames.length}',
        location: loc,
      );
    }
    return resolved.call(const <Object?>[]);
  }

  /// Resolves a runtime method call on a non-builder target.
  ///
  /// Resolves the receiver via the injected expression resolver, then
  /// dispatches to [invokeBuiltinMethod] with the resolved positional
  /// and named arguments. Any failure (arity mismatch, type mismatch,
  /// unknown method, named args) raises [ResolveException] with a
  /// source-span pointer.
  Object? _dispatchRuntimeMethod({
    required MethodInvocation node,
    required RuneContext ctx,
  }) {
    final receiver = _expr.resolve(node.target!, ctx);
    final positional = <Object?>[];
    final named = <String, Object?>{};
    for (final arg in node.argumentList.arguments) {
      if (arg is NamedExpression) {
        named[arg.name.label.name] = _expr.resolve(arg.expression, ctx);
      } else {
        positional.add(_expr.resolve(arg, ctx));
      }
    }
    return invokeBuiltinMethod(
      target: receiver,
      methodName: node.methodName.name,
      positionalArgs: positional,
      namedArgs: named,
      sourceNode: node,
      ctx: ctx,
    );
  }

  /// Extracts `(typeName, constructorName?)` from an explicit `new`-form
  /// call (e.g. `new Text('hi')`, `new EdgeInsets.all(16)`), accounting for
  /// the analyzer quirk where a named constructor's class name is pushed
  /// into `importPrefix` without type resolution. Dispatches to [_dispatch].
  Object? _resolveInstanceCreation(
    InstanceCreationExpression node,
    RuneContext ctx,
  ) {
    final namedType = node.constructorName.type;
    final String typeName;
    final String? constructorName;
    final importPrefix = namedType.importPrefix?.name.lexeme;
    if (importPrefix != null) {
      // `new Foo.bar(...)` — analyzer pushes the class into importPrefix
      // and puts the named-ctor into `name2` when there is no type
      // resolution available. We treat the pair as TypeName.ctor.
      typeName = importPrefix;
      constructorName = namedType.name2.lexeme;
    } else {
      typeName = namedType.name2.lexeme;
      constructorName = node.constructorName.name?.name;
    }
    return _dispatch(
      typeName: typeName,
      constructorName: constructorName,
      argumentList: node.argumentList,
      ctx: ctx,
      source: node.toSource(),
      location: SourceSpan.fromAstOffset(ctx.source, node.offset, node.length),
    );
  }

  Object? _dispatch({
    required String typeName,
    required String? constructorName,
    required ArgumentList argumentList,
    required RuneContext ctx,
    required String source,
    required SourceSpan location,
  }) {
    // Phase F: source-declared components win over every built-in
    // registry so a `RuneComponent(name: 'Text', ...)` declaration can
    // shadow the default Text widget builder.
    final component = ctx.components.find(typeName);
    if (component != null) {
      return _invokeComponent(
        component: component,
        constructorName: constructorName,
        argumentList: argumentList,
        ctx: ctx,
        source: source,
        location: location,
      );
    }
    final widgetBuilder = ctx.widgets.find(typeName);
    if (widgetBuilder != null) {
      final args = _resolveArguments(argumentList, ctx);
      return _runBuilder(
        () => widgetBuilder.build(args, ctx),
        invocationLocation: location,
      );
    }
    final valueBuilder = ctx.values.findValue(
      typeName,
      constructorName: constructorName,
    );
    if (valueBuilder != null) {
      final args = _resolveArguments(argumentList, ctx);
      return _runBuilder(
        () => valueBuilder.build(args, ctx),
        invocationLocation: location,
      );
    }
    throw UnregisteredBuilderException(source, typeName, location: location);
  }

  /// Invokes [build] and, if it raises an [ArgumentException] with no
  /// [RuneException.location] set, rewraps the exception with
  /// [invocationLocation] before rethrowing.
  ///
  /// Builders have no AST in hand — their `args.require*` throws have a
  /// `null` location. The invocation resolver is one level up and holds
  /// the call node's span, which is the right pointer for a missing-arg
  /// diagnostic. Exceptions that already carry a location (e.g., a
  /// [BindingException] raised during sub-argument resolution) are not
  /// touched here at all — only [ArgumentException] is caught, and only
  /// when its location is null. Deeper spans are always more precise
  /// than the invocation's coarser one and must not be overwritten.
  T _runBuilder<T>(
    T Function() build, {
    required SourceSpan invocationLocation,
  }) {
    try {
      return build();
    } on ArgumentException catch (e) {
      if (e.location != null) rethrow;
      throw ArgumentException(
        e.source,
        e.message,
        location: invocationLocation,
      );
    }
  }

  /// Invokes a Phase-F source-declared [component] with the call's
  /// named arguments.
  ///
  /// Components accept named arguments only; positional calls and
  /// named-constructor shapes raise [ResolveException]. The call's
  /// named arguments are resolved against the enclosing context, then
  /// reordered into positional values in the order declared by
  /// [RuneComponent.parameterNames] before being passed to
  /// [RuneComponent.body]. Missing or extra names raise
  /// [ResolveException] with a diagnostic message pointing at the
  /// call site.
  Object? _invokeComponent({
    required RuneComponent component,
    required String? constructorName,
    required ArgumentList argumentList,
    required RuneContext ctx,
    required String source,
    required SourceSpan location,
  }) {
    if (constructorName != null) {
      throw ResolveException(
        source,
        'Component ${component.name} does not accept a named '
        'constructor (got ${component.name}.$constructorName)',
        location: location,
      );
    }
    final named = <String, Object?>{};
    for (final arg in argumentList.arguments) {
      if (arg is! NamedExpression) {
        throw ResolveException(
          source,
          'Component ${component.name} accepts only named arguments; '
          'got a positional argument',
          location: location,
        );
      }
      named[arg.name.label.name] = _expr.resolve(arg.expression, ctx);
    }
    for (final name in named.keys) {
      if (!component.parameterNames.contains(name)) {
        throw ResolveException(
          source,
          'Component ${component.name} does not declare parameter '
          '"$name" (declared: ${component.parameterNames.join(', ')})',
          location: location,
        );
      }
    }
    final positional = <Object?>[];
    for (final paramName in component.parameterNames) {
      if (!named.containsKey(paramName)) {
        throw ResolveException(
          source,
          'Component ${component.name} missing required argument '
          '"$paramName"',
          location: location,
        );
      }
      positional.add(named[paramName]);
    }
    return component.body(positional);
  }

  ResolvedArguments _resolveArguments(ArgumentList list, RuneContext ctx) {
    final positional = <Object?>[];
    final named = <String, Object?>{};
    for (final arg in list.arguments) {
      if (arg is NamedExpression) {
        named[arg.name.label.name] = _expr.resolve(arg.expression, ctx);
      } else {
        positional.add(_expr.resolve(arg, ctx));
      }
    }
    return ResolvedArguments(positional: positional, named: named);
  }
}

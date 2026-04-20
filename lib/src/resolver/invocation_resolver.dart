import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter/material.dart';
import 'package:rune/src/builders/imperative_helpers.dart';
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
      // v1.16.0 pluggable imperative registry: host + sibling bridges
      // can register custom imperatives under bare names (e.g.
      // `showToast(message: 'hi')`). Consulted FIRST so hosts can
      // shadow a built-in bridge when they need to swap Flutter's
      // imperative for a custom one.
      final registeredBare =
          ctx.imperatives?.findBare(node.methodName.name);
      if (registeredBare != null) {
        return _resolveImperativeBridge(node, ctx, registeredBare);
      }
      // v1.3.0 imperative bridges: bare-identifier calls that route to
      // Flutter's imperative modal/overlay APIs rather than a builder.
      // Checked before the registry lookup so a host-registered widget
      // or value cannot shadow the bridge keyword.
      final bridge = _imperativeBridges[node.methodName.name];
      if (bridge != null) {
        return _resolveImperativeBridge(node, ctx, bridge);
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
      // v1.16.0 pluggable imperative registry (prefixed shape): host +
      // sibling bridges can register `Prefix.method(...)` imperatives
      // (e.g. `Router.go('/path')` from rune_router). Consulted FIRST
      // so hosts can shadow a built-in `Navigator.*` bridge by
      // registering a same-named handler.
      final registeredPrefixed = ctx.imperatives?.findPrefixed(
        target.name,
        node.methodName.name,
      );
      if (registeredPrefixed != null) {
        return _resolveImperativeBridge(node, ctx, registeredPrefixed);
      }
      // v1.3.0 + v1.6.0 `Navigator.*(...)` bridges: a `Navigator`-prefixed
      // call with a whitelisted method name dispatches to the matching
      // imperative Navigator bridge rather than the runtime-method path.
      // Placed before the component/value/widget lookups so no host-
      // registered builder named `Navigator` can shadow it.
      if (target.name == 'Navigator') {
        final navBridge = _navigatorBridges[node.methodName.name];
        if (navBridge != null) {
          return _resolveImperativeBridge(node, ctx, navBridge);
        }
      }
      // v1.4.0 context accessors: `Theme.of(ctx)` and
      // `MediaQuery.of(ctx)` yield the enclosing Flutter theme/media-query
      // as plain data values that downstream property access (via the
      // built-in property whitelist) can read. Placed before the
      // component/value/widget lookups so no host-registered builder
      // named `Theme` or `MediaQuery` can shadow them.
      if (node.methodName.name == 'of') {
        if (target.name == 'Theme') {
          return _resolveContextAccessor(node, ctx, 'Theme.of', _readTheme);
        }
        if (target.name == 'MediaQuery') {
          return _resolveContextAccessor(
            node,
            ctx,
            'MediaQuery.of',
            _readMediaQuery,
          );
        }
      }
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
      // When a named constructor is present (e.g. `ListView.builder(...)`),
      // consult the value registry first. Widget builders are default-
      // constructor-only; a constructor-name suffix means the source
      // author wants a value-builder variant even if a plain widget
      // builder of the same type is registered (such as `ListView`
      // itself pairing with `ListView.builder`).
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
      final widgetBuilder = ctx.widgets.find(typeName);
      if (widgetBuilder != null) {
        final args = _resolveArguments(node.argumentList, ctx);
        return _runBuilder(
          () => widgetBuilder.build(args, ctx),
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
    // v1.17.0 MemberRegistry: host + sibling bridges can register
    // method invokers on custom types. Consulted BEFORE the built-in
    // whitelist, BUT ONLY when [receiver] is not a recognized
    // built-in target type. This preserves the built-in-first
    // invariant for stock types (String, List, Map, ThemeData, etc.)
    // so a host cannot accidentally shadow `.toUpperCase()` or
    // similar with a custom registration; custom classes on the
    // other hand never collide with the built-in table, so the
    // registry-first semantics apply cleanly. Named arguments fall
    // through to the built-in boundary, which rejects them
    // uniformly.
    final members = ctx.members;
    if (members != null &&
        named.isEmpty &&
        builtinTargetTypeLabel(receiver) == null) {
      final (hit, value) = members.invokeMethod(
        receiver,
        node.methodName.name,
        positional,
        ctx,
      );
      if (hit) return value;
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
    // When a named constructor is present, the value registry is the
    // correct first stop (widget builders are default-constructor-only
    // and would otherwise swallow `ListView.builder(...)` as if it were
    // bare `ListView(...)`).
    if (constructorName != null) {
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
    throw UnregisteredBuilderException.withSuggestion(
      source,
      typeName,
      _builderCandidates(ctx),
      location: location,
    );
  }

  /// Concatenates every registered builder name — widgets, value-builder
  /// type names (stripped of `.ctor`), and in-scope components — for the
  /// "did you mean ...?" Levenshtein lookup at unregistered-builder
  /// throw sites. Iteration order follows the registries' own insertion
  /// order, which keeps suggestions deterministic across runs.
  Iterable<String> _builderCandidates(RuneContext ctx) sync* {
    yield* ctx.widgets.names;
    yield* ctx.values.typeNames;
    yield* ctx.components.names;
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

  /// Resolves a v1.3.0 imperative bridge call: walks the argument list
  /// via the injected expression resolver, then delegates to [bridge]
  /// with the resulting [ResolvedArguments] and the current
  /// [RuneContext].
  ///
  /// Mirrors the [_runBuilder] wrapper so an [ArgumentException] raised
  /// by the bridge with no [RuneException.location] set gets rewrapped
  /// with the invocation's source span before being rethrown. Deeper
  /// spans already attached to upstream failures are preserved.
  Object? _resolveImperativeBridge(
    MethodInvocation node,
    RuneContext ctx,
    Object? Function(ResolvedArguments args, RuneContext ctx) bridge,
  ) {
    final args = _resolveArguments(node.argumentList, ctx);
    final location =
        SourceSpan.fromAstOffset(ctx.source, node.offset, node.length);
    return _runBuilder(
      () => bridge(args, ctx),
      invocationLocation: location,
    );
  }

  /// Resolves a v1.4.0 context accessor (`Theme.of(ctx)` or
  /// `MediaQuery.of(ctx)`) by validating that exactly one positional
  /// argument was supplied, resolving it to a [BuildContext], and
  /// delegating to [reader] to look up the per-accessor Flutter value.
  ///
  /// All three failure modes surface as [ResolveException] with a
  /// source-span pointer at the call site:
  ///
  /// 1. Named arguments supplied.
  /// 2. Positional arity != 1.
  /// 3. The resolved positional value is not a [BuildContext].
  Object? _resolveContextAccessor(
    MethodInvocation node,
    RuneContext ctx,
    String accessorName,
    Object? Function(BuildContext context) reader,
  ) {
    final argList = node.argumentList.arguments;
    final location =
        SourceSpan.fromAstOffset(ctx.source, node.offset, node.length);
    final named =
        argList.whereType<NamedExpression>().toList(growable: false);
    if (named.isNotEmpty) {
      throw ResolveException(
        node.toSource(),
        '$accessorName does not accept named arguments; '
        'got ${named.map((n) => n.name.label.name).join(", ")}',
        location: location,
      );
    }
    final positional = argList
        .where((a) => a is! NamedExpression)
        .toList(growable: false);
    if (positional.length != 1) {
      throw ResolveException(
        node.toSource(),
        '$accessorName expects exactly one positional BuildContext '
        'argument, got ${positional.length}',
        location: location,
      );
    }
    final resolved = _expr.resolve(positional.single, ctx);
    if (resolved is! BuildContext) {
      throw ResolveException(
        node.toSource(),
        '$accessorName expects a BuildContext argument; '
        'got ${resolved.runtimeType}',
        location: location,
      );
    }
    return reader(resolved);
  }

  /// Whitelist of bare-identifier imperative bridge calls.
  ///
  /// Entries route from the Rune source identifier (`showDialog`,
  /// `showModalBottomSheet`, `showSnackBar`) to the top-level helper
  /// in `imperative_helpers.dart`. `Navigator.*` entries are not listed
  /// here because they are shaped as `SimpleIdentifier`-target
  /// [MethodInvocation]s and handled via [_navigatorBridges] in the
  /// target-branch above.
  static final Map<
      String,
      Object? Function(ResolvedArguments args, RuneContext ctx)
  > _imperativeBridges = <String,
      Object? Function(ResolvedArguments args, RuneContext ctx)>{
    'showDialog': runShowDialog,
    'showModalBottomSheet': runShowModalBottomSheet,
    'showSnackBar': runShowSnackBar,
    'showDatePicker': runShowDatePicker,
    'showTimePicker': runShowTimePicker,
    'showMenu': runShowMenu,
  };

  /// Whitelist of `Navigator.<method>(...)` imperative bridge calls.
  ///
  /// Entries route from the Rune source method name (`pop`, `push`,
  /// `pushNamed`, `pushReplacement`, `canPop`) to the top-level helper
  /// in `imperative_helpers.dart`. Placed in a dedicated map so the
  /// target-branch dispatch stays a single O(1) lookup and the set of
  /// supported Navigator methods is explicit at a glance.
  static final Map<
      String,
      Object? Function(ResolvedArguments args, RuneContext ctx)
  > _navigatorBridges = <String,
      Object? Function(ResolvedArguments args, RuneContext ctx)>{
    'pop': runNavigatorPop,
    'push': runNavigatorPush,
    'pushReplacement': runNavigatorPushReplacement,
    'pushNamed': runNavigatorPushNamed,
    'canPop': runNavigatorCanPop,
    'popUntil': runNavigatorPopUntil,
  };
}

/// Reads [Theme.of] off the supplied [context]. Top-level helper for
/// [InvocationResolver._resolveContextAccessor] dispatch on `Theme.of(ctx)`.
ThemeData _readTheme(BuildContext context) => Theme.of(context);

/// Reads [MediaQuery.of] off the supplied [context]. Top-level helper for
/// [InvocationResolver._resolveContextAccessor] dispatch on
/// `MediaQuery.of(ctx)`.
MediaQueryData _readMediaQuery(BuildContext context) =>
    MediaQuery.of(context);

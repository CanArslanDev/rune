import 'package:analyzer/dart/ast/ast.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/exceptions.dart';
import 'package:rune/src/core/rune_context.dart';
import 'package:rune/src/resolver/expression_resolver.dart';

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
  /// back to [_expr]. The expression resolver must already exist — wire
  /// the back-pointer via [ExpressionResolver.bind] immediately after
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
        ),
    };
  }

  /// Extracts `(typeName, constructorName?)` from a bare call-syntax node
  /// (e.g. `Text('hi')`, `EdgeInsets.all(16)`) and dispatches to [_dispatch].
  Object? _resolveMethodInvocation(MethodInvocation node, RuneContext ctx) {
    final String typeName;
    final String? constructorName;
    final target = node.target;
    if (target == null) {
      // Bare `Text('hi')`.
      typeName = node.methodName.name;
      constructorName = null;
    } else if (target is SimpleIdentifier) {
      // Bare `EdgeInsets.all(16)`.
      typeName = target.name;
      constructorName = node.methodName.name;
    } else {
      throw ResolveException(
        node.toSource(),
        'Unsupported MethodInvocation target shape: '
        '${target.runtimeType}',
      );
    }
    return _dispatch(
      typeName: typeName,
      constructorName: constructorName,
      argumentList: node.argumentList,
      ctx: ctx,
      source: node.toSource(),
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
    );
  }

  Object? _dispatch({
    required String typeName,
    required String? constructorName,
    required ArgumentList argumentList,
    required RuneContext ctx,
    required String source,
  }) {
    final widgetBuilder = ctx.widgets.find(typeName);
    if (widgetBuilder != null) {
      final ResolvedArguments args = _resolveArguments(argumentList, ctx);
      return widgetBuilder.build(args, ctx);
    }
    final valueBuilder = ctx.values.findValue(
      typeName,
      constructorName: constructorName,
    );
    if (valueBuilder != null) {
      final ResolvedArguments args = _resolveArguments(argumentList, ctx);
      return valueBuilder.build(args, ctx);
    }
    throw UnregisteredBuilderException(source, typeName);
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

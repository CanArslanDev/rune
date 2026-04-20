/// Rune — runtime Dart-widget-string to Flutter widget interpreter.
///
/// Public API surface is re-exported from this library. Consumers should
/// `import 'package:rune/rune.dart';` and never reach into `src/`.
library rune;

export 'src/binding/rune_data_context.dart' show RuneDataContext;
export 'src/binding/rune_event_dispatcher.dart' show RuneEventDispatcher;
export 'src/bridges/rune_bridge.dart' show RuneBridge;
export 'src/builders/builder.dart'
    show RuneBuilder, RuneValueBuilder, RuneWidgetBuilder;
export 'src/builders/event_callback.dart'
    show valueEventCallback, voidEventCallback;
export 'src/builders/resolved_arguments.dart' show ResolvedArguments;
export 'src/config.dart' show RuneConfig;
export 'src/core/exceptions.dart';
export 'src/core/rune_component.dart' show RuneComponent;
export 'src/core/rune_context.dart' show RuneContext;
export 'src/core/source_span.dart' show SourceSpan;
export 'src/defaults/rune_defaults.dart' show RuneDefaults;
export 'src/dev/rune_dev_overlay.dart' show RuneDevOverlay;
export 'src/dev/rune_source_formatter.dart' show formatRuneSource;
export 'src/dynamic_view.dart' show RuneView;
export 'src/registry/component_registry.dart' show ComponentRegistry;
export 'src/registry/constant_registry.dart' show ConstantRegistry;
export 'src/registry/extension_registry.dart'
    show ExtensionRegistry, RuneExtensionHandler;
export 'src/registry/imperative_registry.dart'
    show ImperativeHandler, ImperativeRegistry;
export 'src/registry/member_registry.dart'
    show MemberMethodInvoker, MemberPropertyAccessor, MemberRegistry;
export 'src/registry/registry.dart' show Registry;
export 'src/registry/value_registry.dart' show ValueRegistry;
export 'src/registry/widget_registry.dart' show WidgetRegistry;

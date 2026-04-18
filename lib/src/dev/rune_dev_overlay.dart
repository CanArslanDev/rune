import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A developer-only inspector that wraps an arbitrary child widget
/// (typically a `RuneView`) and opens a bottom sheet on long-press
/// showing the underlying source + a brief render summary.
///
/// In release builds the long-press handler is NOT registered — the
/// overlay passes through transparently. In debug and profile builds,
/// long-pressing the child opens a `showModalBottomSheet` with a
/// recognisable header, the source text, and an approximate widget
/// count.
///
/// This class is opt-in. Wrap a `RuneView` (or any widget tree) with
/// it during development; remove the wrapper or leave it — the
/// release-build pass-through makes it zero-cost in production.
///
/// For richer instrumentation (per-registry dispatch counts, AST
/// visualisation), extend this widget or build a custom replacement
/// — the hooks are intentionally simple here.
final class RuneDevOverlay extends StatelessWidget {
  /// Wraps [child]. If [sourceProvider] is supplied, its return value
  /// is displayed verbatim in the overlay; otherwise the overlay
  /// displays a placeholder because walking descendants for a source
  /// is brittle.
  const RuneDevOverlay({
    required this.child,
    this.sourceProvider,
    super.key,
  });

  /// The wrapped widget — typically a `RuneView`, but any widget tree
  /// is allowed.
  final Widget child;

  /// Optional function that returns the raw source string being
  /// inspected. If null, the overlay displays `<source unavailable>`.
  /// Supplying this explicitly is the most reliable way to surface
  /// the source — walking child widgets is brittle.
  final String Function()? sourceProvider;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return child;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () => _openInspector(context),
      child: child,
    );
  }

  void _openInspector(BuildContext context) {
    final source = sourceProvider?.call() ?? '<source unavailable>';
    final widgetCount = _countDescendants(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetCtx) => _InspectorSheet(
        source: source,
        widgetCount: widgetCount,
      ),
    );
  }

  int _countDescendants(BuildContext context) {
    var count = 0;
    void visit(Element element) {
      count++;
      element.visitChildren(visit);
    }

    if (context is Element) {
      context.visitChildren(visit);
    }
    return count;
  }
}

class _InspectorSheet extends StatelessWidget {
  const _InspectorSheet({
    required this.source,
    required this.widgetCount,
  });

  final String source;
  final int widgetCount;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      builder: (ctx, scrollController) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rune dev overlay',
              style: Theme.of(ctx).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              '$widgetCount descendants rendered',
              style: Theme.of(ctx).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            const Divider(),
            Expanded(
              child: ListView(
                controller: scrollController,
                children: [
                  Text(
                    'Source',
                    style: Theme.of(ctx).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    source,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

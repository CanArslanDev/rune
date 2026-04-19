import 'package:flutter/material.dart';
import 'package:rune/src/builders/builder.dart';
import 'package:rune/src/builders/closure_builder_helpers.dart';
import 'package:rune/src/builders/resolved_arguments.dart';
import 'package:rune/src/core/rune_context.dart';

/// Builds `SearchAnchor.bar(...)` - Material 3's composed search surface
/// that shows a [SearchBar] and opens a suggestions view on tap.
///
/// Registered as a [RuneValueBuilder] because `SearchAnchor.bar` is a
/// named constructor; dispatch runs through the value registry even
/// though the returned value is a [Widget].
///
/// Required:
/// - `suggestionsBuilder` (closure of arity 2) -
///   `(BuildContext, SearchController) -> List<Widget>`. Evaluated every
///   time the view needs to refresh suggestions. Non-[Widget] returns
///   are filtered out.
///
/// Optional:
/// - `searchController` ([SearchController]?).
/// - `viewHintText`, `barHintText` ([String]?).
/// - `barLeading` ([Widget]?).
/// - `barTrailing` (`List<Widget>?`). Non-[Widget] entries are filtered.
/// - `isFullScreen` ([bool]?).
final class SearchAnchorBarBuilder implements RuneValueBuilder {
  /// Const constructor - the builder is stateless.
  const SearchAnchorBarBuilder();

  @override
  String get typeName => 'SearchAnchor';

  @override
  String? get constructorName => 'bar';

  @override
  Widget build(ResolvedArguments args, RuneContext ctx) {
    final suggestionsBuilder = toSearchSuggestionsBuilder(
      args.named['suggestionsBuilder'],
      'SearchAnchor.bar',
    );
    final rawTrailing = args.get<List<Object?>>('barTrailing');
    final barTrailing =
        rawTrailing?.whereType<Widget>().toList(growable: false);
    // Flutter 3.41's SearchAnchor.bar factory declares searchController as
    // non-nullable; the underlying state allocates an internal controller
    // when the consumer does not supply one. When a source author binds
    // their own controller we forward it, otherwise we materialise a
    // fresh SearchController per build so the non-null contract is met
    // without forcing source to allocate.
    final providedController =
        args.get<SearchController>('searchController');
    return SearchAnchor.bar(
      suggestionsBuilder: suggestionsBuilder,
      searchController: providedController ?? SearchController(),
      viewHintText: args.get<String>('viewHintText'),
      barHintText: args.get<String>('barHintText'),
      barLeading: args.get<Widget>('barLeading'),
      barTrailing: barTrailing,
      isFullScreen: args.get<bool>('isFullScreen'),
    );
  }
}

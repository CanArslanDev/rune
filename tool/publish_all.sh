#!/usr/bin/env bash
# End-to-end release workflow across the rune monorepo.
#
# Handles the order-sensitive step that caused historical bloat in
# the main `rune` archive: if the DevTools extension's compiled
# Flutter-web bundle is sitting on disk when we publish the main
# package, it gets swept into the `rune` archive (~12 MB extra,
# because `dart pub publish` does not understand that
# `packages/rune_devtools_extension/extension/devtools/build/`
# belongs to a separate sibling package). Workaround: build the
# bundle, publish the extension, delete the bundle, then publish
# main `rune`.
#
# Rate-limited by pub.dev (12 publishes per 24h per account); if
# you have queued up several releases in one burst and hit the
# cap mid-run, rerun the script the next day and pass
# `--skip-already-published` once that flag is implemented.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXT_DIR="$REPO_ROOT/packages/rune_devtools_extension"
BUNDLE_DIR="$EXT_DIR/extension/devtools/build"

publish() {
  local dir="$1"
  local label="$2"
  echo
  echo "=== Publishing $label from $dir ==="
  cd "$dir"
  dart pub publish --force
}

# 1. Build the DevTools extension bundle and publish the sibling
#    while the bundle is in place on disk.
echo "=== Building rune_devtools_extension bundle ==="
bash "$EXT_DIR/tool/build_bundle.sh"
publish "$EXT_DIR" "rune_devtools_extension"

# 2. Remove the compiled bundle so it does not leak into any
#    subsequent publish archive.
echo
echo "=== Cleaning compiled bundle ==="
rm -rf "$BUNDLE_DIR"

# 3. Publish the other siblings (order within this block is
#    unimportant).
publish "$REPO_ROOT/packages/rune_responsive_sizer" "rune_responsive_sizer"
publish "$REPO_ROOT/packages/rune_cupertino" "rune_cupertino"
publish "$REPO_ROOT/packages/rune_provider" "rune_provider"
publish "$REPO_ROOT/packages/rune_router" "rune_router"

# 4. Finally publish the main `rune` package. With the bundle gone
#    the archive comes in at ~370 KB compressed.
publish "$REPO_ROOT" "rune (main)"

echo
echo "All packages published."

#!/usr/bin/env bash
# End-to-end release workflow across the rune monorepo.
#
# Publish order matters:
#
# 1. Main `rune` must land on pub.dev FIRST. Every sibling
#    package declares `rune: ^1.X.Y` in its `dependencies:` and
#    pub.dev validates that constraint against the hosted
#    registry at publish time. If a sibling publishes before the
#    matching `rune` minor is live, the validator errors out.
# 2. `rune_devtools_extension` needs the compiled Flutter-web
#    bundle sitting under `extension/devtools/build/` when its
#    archive is built. We produce the bundle via
#    `packages/rune_devtools_extension/tool/build_bundle.sh`
#    right before that step, and delete it right after.
# 3. The remaining siblings publish in any order once `rune`
#    is on pub.dev.
#
# Also: main `rune` archive is small only if the DevTools bundle
# is NOT sitting on disk when we publish (dart pub publish would
# otherwise sweep it into the main archive because it walks the
# full subtree of the invocation directory). We make sure the
# bundle is absent before publishing `rune`.
#
# Rate-limit: pub.dev allows 12 publishes / 24h per account.
# Six packages in one run stays comfortably below the cap.

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

# 1. Ensure no stale DevTools bundle is lying around; the main
#    rune archive would otherwise balloon to ~12 MB.
echo "=== Cleaning any stale DevTools bundle ==="
rm -rf "$BUNDLE_DIR"

# 2. Main `rune` lands first so siblings can resolve their
#    hosted `rune: ^1.X.Y` constraint against pub.dev.
publish "$REPO_ROOT" "rune (main)"

# 3. Build the DevTools extension bundle, publish the sibling
#    while the bundle is in place, then delete the bundle so it
#    cannot leak into the other sibling archives.
echo
echo "=== Building rune_devtools_extension bundle ==="
bash "$EXT_DIR/tool/build_bundle.sh"
publish "$EXT_DIR" "rune_devtools_extension"
echo
echo "=== Cleaning compiled bundle ==="
rm -rf "$BUNDLE_DIR"

# 4. Remaining siblings publish in any order.
publish "$REPO_ROOT/packages/rune_responsive_sizer" "rune_responsive_sizer"
publish "$REPO_ROOT/packages/rune_cupertino" "rune_cupertino"
publish "$REPO_ROOT/packages/rune_provider" "rune_provider"
publish "$REPO_ROOT/packages/rune_router" "rune_router"

echo
echo "All packages published."

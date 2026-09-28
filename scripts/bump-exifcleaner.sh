#!/usr/bin/env bash
# Checks for a new ExifCleaner release, and if there is one, updates
# Casks/exifcleaner.rb (version + both sha256 hashes) and opens a pull request.
#
# Env:
#   GITHUB_TOKEN    token for the GitHub API / gh (set automatically in Actions)
#   LATEST_VERSION  optional: skip the API lookup and use this version
#   DRY_RUN=1       optional: update the file only, no branch / commit / PR
set -euo pipefail

UPSTREAM="szTheory/exifcleaner"
CASK="Casks/exifcleaner.rb"
cd "$(dirname "$0")/.."

current=$(sed -nE 's/^  version "([^"]+)"/\1/p' "$CASK")
[ -n "$current" ] || { echo "Could not read current version from $CASK" >&2; exit 1; }

if [ -z "${LATEST_VERSION:-}" ]; then
  auth=()
  [ -n "${GITHUB_TOKEN:-}" ] && auth=(-H "Authorization: Bearer $GITHUB_TOKEN")
  tag=$(curl -fsSL "${auth[@]}" "https://api.github.com/repos/$UPSTREAM/releases/latest" \
        | python3 -c 'import json,sys; print(json.load(sys.stdin)["tag_name"])')
  LATEST_VERSION="${tag#v}"
fi
latest="$LATEST_VERSION"

echo "Current: $current  Latest: $latest"
if [ "$current" = "$latest" ]; then
  echo "Up to date."
  exit 0
fi
# Never go backwards (e.g. if upstream re-marks an older release as latest).
if [ "$(printf '%s\n%s\n' "$current" "$latest" | sort -V | tail -1)" != "$latest" ]; then
  echo "Latest ($latest) is not newer than current ($current); nothing to do."
  exit 0
fi

branch="bump-exifcleaner-$latest"
if [ -z "${DRY_RUN:-}" ] && git ls-remote --exit-code --heads origin "$branch" >/dev/null 2>&1; then
  echo "Branch $branch already exists (PR probably open already)."
  exit 0
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
base="https://github.com/$UPSTREAM/releases/download/v$latest"
echo "Downloading release files..."
curl -fsSL -o "$tmp/arm.dmg"   "$base/ExifCleaner-$latest-arm64.dmg"
curl -fsSL -o "$tmp/intel.dmg" "$base/ExifCleaner-$latest.dmg"
sha_arm=$(sha256sum "$tmp/arm.dmg" | cut -d' ' -f1)
sha_intel=$(sha256sum "$tmp/intel.dmg" | cut -d' ' -f1)
size_arm=$(du -h "$tmp/arm.dmg" | cut -f1)
size_intel=$(du -h "$tmp/intel.dmg" | cut -f1)

sed -i -E \
  -e "s/^  version \"[^\"]+\"/  version \"$latest\"/" \
  -e "s/(sha256 arm: +\")[0-9a-f]{64}\"/\1$sha_arm\"/" \
  -e "s/(intel: +\")[0-9a-f]{64}\"/\1$sha_intel\"/" \
  "$CASK"

grep -q "version \"$latest\"" "$CASK" && grep -q "$sha_arm" "$CASK" && grep -q "$sha_intel" "$CASK" \
  || { echo "Failed to update $CASK" >&2; exit 1; }
echo "Updated $CASK to $latest"

if [ -n "${DRY_RUN:-}" ]; then
  git --no-pager diff -- "$CASK" 2>/dev/null || true
  exit 0
fi

git config user.name  "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
git checkout -b "$branch"
git add "$CASK"
git commit -m "exifcleaner $current -> $latest"
git push origin "$branch"

gh pr create --base main --head "$branch" \
  --title "exifcleaner $current -> $latest" \
  --body "$(cat <<EOF
Automated update of **ExifCleaner** from \`$current\` to \`$latest\`.

**Before merging, check:**
- [ ] The download URL in the diff still points to \`github.com/$UPSTREAM\` (nothing else changed)
- [ ] Release notes look normal: https://github.com/$UPSTREAM/releases/tag/v$latest

| Build | SHA-256 | Size |
|---|---|---|
| Apple Silicon (\`ExifCleaner-$latest-arm64.dmg\`) | \`$sha_arm\` | $size_arm |
| Intel (\`ExifCleaner-$latest.dmg\`) | \`$sha_intel\` | $size_intel |

After merging, on your Mac: \`brew update && brew upgrade --cask exifcleaner\`
EOF
)"

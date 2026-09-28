# nibres/homebrew-tap

My own Homebrew tap, so I don't have to trust third-party taps.

| Cask | Source |
|---|---|
| `exifcleaner` | official releases of [szTheory/exifcleaner](https://github.com/szTheory/exifcleaner/releases) |

## Install

```sh
brew install --cask nibres/tap/exifcleaner
```

Homebrew adds this tap automatically. ExifCleaner is unsigned; the cask verifies the
download's SHA-256 and then removes the quarantine flag from `ExifCleaner.app` only,
so it opens without the Privacy & Security prompt.

## How updates work

- Every Monday the **Check for app updates** workflow looks at the latest ExifCleaner release.
- If there's a new version it downloads both builds (Apple Silicon + Intel), computes the
  SHA-256 hashes and opens a pull request. GitHub emails you about it.
- Review the diff — the URL must still point at `szTheory/exifcleaner` — and merge.
- Then on the Mac: `brew update && brew upgrade --cask exifcleaner`

Nothing reaches the Mac until the PR is merged. The workflow can also be started by hand:
**Actions → Check for app updates → Run workflow**.

Requires (one-time): **Settings → Actions → General → Workflow permissions →
"Allow GitHub Actions to create and approve pull requests"**.

## Manual update

```sh
LATEST_VERSION=4.5.0 DRY_RUN=1 ./scripts/bump-exifcleaner.sh   # edits the cask only
```

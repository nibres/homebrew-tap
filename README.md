# homebrew-tap

My own Homebrew tap, so I don't have to trust third-party taps. Every package here
downloads official upstream releases only, verified by SHA-256.

## Packages

| Package | Type | Source | Notes |
|---|---|---|---|
| `exifcleaner` | cask | [szTheory/exifcleaner](https://github.com/szTheory/exifcleaner/releases) | [Unsigned app](#exifcleaner) |

## Install

```sh
brew install --cask nibres/tap/<cask>     # casks (apps)
brew install nibres/tap/<formula>         # formulae (CLI tools)
```

Homebrew adds this tap automatically on first install. To add it without installing
anything: `brew tap nibres/tap`.

## How updates work

- Every Monday the **Check for app updates** workflow runs one job per package.
- Each job runs `scripts/bump-<package>.sh`. If upstream has a new release, the script
  downloads the release files, computes the SHA-256 hashes and opens a pull request.
  GitHub emails you about it.
- Review the diff (the download URL must still point at the upstream repo) and merge.
- Then on the Mac: `brew update && brew upgrade`

Nothing reaches the Mac until the PR is merged. The workflow can also be started by hand:
**Actions → Check for app updates → Run workflow**.

Requires (one-time): **Settings → Actions → General → Workflow permissions →
"Allow GitHub Actions to create and approve pull requests"**.

### Manual update

Every bump script accepts the same environment variables:

```sh
LATEST_VERSION=1.2.3 DRY_RUN=1 ./scripts/bump-<package>.sh   # edits the file only
```

- `LATEST_VERSION`: skip the upstream lookup and use this version.
- `DRY_RUN=1`: update the cask/formula only. No branch, commit or PR.

## Adding a package

1. Add `Casks/<name>.rb` (app) or `Formula/<name>.rb` (CLI tool).
2. Add `scripts/bump-<name>.sh`. Copy `scripts/bump-exifcleaner.sh` and change
   `UPSTREAM`, the file path and the download URLs.
3. Add a job for it in `.github/workflows/autobump.yml`.
4. Add a row to the [Packages](#packages) table, plus a section below if it needs notes.
5. Test locally: `brew install --cask ./Casks/<name>.rb` and `brew audit --cask nibres/tap/<name>`.

## Package notes

### exifcleaner

ExifCleaner is unsigned. The cask verifies the download's SHA-256, then removes the
quarantine flag from `ExifCleaner.app` only, so it opens without the
Privacy & Security prompt. Both Apple Silicon and Intel builds are supported.

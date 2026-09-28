# My private Homebrew tap

Casks I maintain myself instead of trusting a third-party tap.

| Cask | Source |
|---|---|
| `exifcleaner` | official releases of [szTheory/exifcleaner](https://github.com/szTheory/exifcleaner/releases) |

## One-time setup

1. On GitHub, create a **private** repo named exactly `homebrew-tap` (the `homebrew-` prefix is required).
2. Push this folder:
   ```sh
   cd homebrew-tap
   git init -b main
   git add -A
   git commit -m "Initial tap"
   git remote add origin git@github.com:YOURNAME/homebrew-tap.git
   git push -u origin main
   ```
3. In the repo: **Settings → Actions → General → Workflow permissions** →
   tick **"Allow GitHub Actions to create and approve pull requests"** → Save.
   (Without this, the update check runs but can't open the PR.)
4. Test it once: **Actions → Check for app updates → Run workflow**.
   It should finish green with "Up to date."
5. On your Mac (private repos need the SSH URL):
   ```sh
   brew tap YOURNAME/tap git@github.com:YOURNAME/homebrew-tap.git
   brew install --cask YOURNAME/tap/exifcleaner
   ```
   First launch: the app is unsigned, so open it once, then
   System Settings → Privacy & Security → **Open Anyway**.

## How updates work

- Every Monday a GitHub Action checks the latest ExifCleaner release.
- If there's a new version, it downloads both builds, computes the SHA-256 hashes,
  and opens a pull request. GitHub emails you about it.
- You review the diff (the URL should still point at `szTheory/exifcleaner`) and merge.
- Then on your Mac: `brew update && brew upgrade --cask exifcleaner`

Nothing reaches your Mac until you merge.

## Manual update (if ever needed)

```sh
LATEST_VERSION=4.5.0 DRY_RUN=1 ./scripts/bump-exifcleaner.sh   # edits the cask only
```

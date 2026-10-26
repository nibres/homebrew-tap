cask "exifcleaner" do
  arch arm: "-arm64"

  version "4.7.0"
  sha256 arm:   "a58f1b730be2e9ad9241d405cc4b40d6762e56c81710fd7f7251b6f97e3cddcf",
         intel: "ebea37ec7e6e22ad556da596caf7208c68c14ddecc8567183ab41864f8cbd344"

  url "https://github.com/szTheory/exifcleaner/releases/download/v#{version}/ExifCleaner-#{version}#{arch}.dmg"
  name "ExifCleaner"
  desc "Metadata cleaner"
  homepage "https://exifcleaner.com/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :monterey

  app "ExifCleaner.app"

  # The app is unsigned, so Gatekeeper would block it on every install/upgrade.
  # The download is checksum-verified against the official release above, so
  # remove the quarantine flag from this one app only.
  postflight_steps do
    run "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "{{appdir}}/ExifCleaner.app"]
  end

  zap trash: [
    "~/Library/Application Support/ExifCleaner",
    "~/Library/Preferences/com.exifcleaner.plist",
    "~/Library/Saved Application State/com.exifcleaner.savedState",
  ]
end

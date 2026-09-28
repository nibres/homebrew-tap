cask "exifcleaner" do
  arch arm: "-arm64"

  version "4.4.0"
  sha256 arm:   "78b79caddf6fe96ec39253cae27a28e6bd2877a3401b74cde6108d65344afdb5",
         intel: "909a180ec171906b2ac69506cb6dcc2db7de66c0f0f1e9d40c2b604d10c7777a"

  url "https://github.com/szTheory/exifcleaner/releases/download/v#{version}/ExifCleaner-#{version}#{arch}.dmg"
  name "ExifCleaner"
  desc "Metadata cleaner"
  homepage "https://exifcleaner.com/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: ">= :monterey"

  app "ExifCleaner.app"

  # No quarantine removal on purpose: the app is unsigned, so on first launch
  # approve it once in System Settings -> Privacy & Security -> "Open Anyway".

  zap trash: [
    "~/Library/Application Support/ExifCleaner",
    "~/Library/Preferences/com.exifcleaner.plist",
    "~/Library/Saved Application State/com.exifcleaner.savedState",
  ]
end

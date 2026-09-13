cask "sankore" do
  version "1.3"
  sha256 "1b54b69ea89b35329cd1f6722232e17545c48a3c0abe2a29ad3c806cc79d4675"

  url "https://dl.sankoreapp.com/Sankore-#{version}.dmg"
  name "Sankore"
  desc "Local-first document to Markdown converter"
  homepage "https://sankoreapp.com/"

  livecheck do
    url "https://sankoreapp.com/version.json"
    strategy :json do |json|
      json["latest_version"]
    end
  end

  depends_on macos: :big_sur

  app "Sankore.app"

  zap trash: [
    "~/Library/Application Support/Sankore",
    "~/Library/Caches/com.directiveinsights.sankore",
    "~/Library/Logs/sankore.log",
    "~/Library/Preferences/com.directiveinsights.sankore.plist",
    "~/Sankore/.ui_prefs.json",
    "~/Sankore/.update_cache.json",
  ]
end

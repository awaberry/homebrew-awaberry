class Awaberry < Formula
  desc "AwaBerry installer for macOS (brew based)"
  homepage "https://www.awaberry.com"
  url "https://raw.githubusercontent.com/awaberry/awaberry/main/connect/mac/macbrewinstaller.sh"
  version "1.0.0"
  sha256 "5b6041bdebc1194144d3648ab570537dc7beb2f228098bab4b6b3faa27f986fc"

  depends_on "screen"
  depends_on "jq"
  depends_on "wget"
  depends_on "openssl"
  depends_on "zip"
  depends_on "unzip"
  depends_on "openjdk@21"

  def install
    bin.install "macbrewinstaller.sh" => "awaberry"
    chmod 0755, bin/"awaberry"
  end

# downlod install script
# curl -s https://raw.githubusercontent.com/awaberry/awaberry/main/install.sh -o install.sh

# brew services list - list of services
# brew reinstall --build-from-source ./awaberry.rb
# brew services start awaberry - start the service
# brew services stop awaberry - stop the service


service do
  run [
    "sh",
    "-c",
    "#{ENV["HOME"]}/awaberry/awaberryclient/update/update.sh && #{ENV["HOME"]}/awaberry/awaberryclient/app/runawaberryclient.sh"
  ]
  working_dir "#{ENV["HOME"]}/awaberry/awaberryclient/app"
  log_path "#{ENV["HOME"]}/awaberry/awaberry.log"
  error_log_path "#{ENV["HOME"]}/awaberry/error.log"
end

  def plist
    <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
        <dict>
          <key>Label</key>
          <string>com.awabon.awaberryclient</string>
          <key>ProgramArguments</key>
          <array>
            <string>java</string>
            <string>-Xmx64m</string>
            <string>-cp</string>
            <string>awaberryclient.jar:lib/*</string>
            <string>com.awabon.client.mainapp.MainAppAwaberryClient</string>
          </array>
          <key>WorkingDirectory</key>
          <string>#{ENV["HOME"]}/awaberry/awaberryclient/app</string>
          <key>RunAtLoad</key>
          <true/>
          <key>StandardOutPath</key>
          <string>#{ENV["HOME"]}/awaberryclient/.awaberrydata/execution.log</string>
          <key>StandardErrorPath</key>
          <string>#{ENV["HOME"]}/awaberry/execution.log</string>
        </dict>
      </plist>
    EOS
  end


  test do
    if File.exist?('>#{ENV["HOME"]}/awaberry/.awaberrydata/execution.log')
      puts "Log file for awaberry exists - client is up."
    else
      puts "File does not exist."
    end
  end
end
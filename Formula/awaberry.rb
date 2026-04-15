class Awaberry < Formula
  desc "AwaBerry installer for macOS (brew based)"
  homepage "https://www.awaberry.com"
  url "https://raw.githubusercontent.com/awaberry/awaberry/main/connect/mac/macbrewinstaller.sh"
  version "1.3.30"
  sha256 "64a631248ef1f1cdbdc372a77cefdc2246784e4b6b2a2cb44d68fc6d26e2caa9"

  depends_on "screen"
  depends_on "jq"
  depends_on "wget"
  depends_on "openssl"
  depends_on "zip"
  depends_on "unzip"
  depends_on "openjdk@21"

  def install


    # Create a named service launcher in libexec.
    # macOS uses the binary basename as the background-item display name,
    # so naming this script "awaberry" makes System Settings show "awaberry"
    # instead of "sh".
    launcher = libexec/"awaberry"
    launcher.write <<~EOS
      #!/bin/bash
      # Run update if it exists (non-fatal - do not block the client on failure)
      if [ -x "$HOME/awaberry/awaberryclient/update/update.sh" ]; then
        "$HOME/awaberry/awaberryclient/update/update.sh" || true
      fi
      # Replace this shell process with the client (exec = no extra process layer)
      exec "$HOME/awaberry/awaberryclient/app/runawaberryclient.sh"
    EOS
    chmod 0755, launcher
  end



  def caveats
    <<~EOS
      awaberry client installer has run and the background service has been started.

      To verify the service is running:
        brew services list

      Useful commands:
        brew services start awaberry   – start  (and enable autostart on login)
        brew services stop  awaberry   – stop   (and disable autostart)
    EOS
  end

  # brew services list                   – list services
  # brew services start awaberry         – start & register autostart on login/reboot
  # brew services stop  awaberry         – stop & unregister autostart
  # brew reinstall --build-from-source ./awaberry.rb

  service do
    # Run the named launcher so macOS reports "awaberry" in background items
    run [opt_libexec/"awaberry"]
    # keep_alive restarts the service if it exits and re-registers it after reboot
    keep_alive true
    working_dir "#{ENV["HOME"]}/awaberry/awaberryclient/app"
    log_path     "#{ENV["HOME"]}/awaberry/awaberry.log"
    error_log_path "#{ENV["HOME"]}/awaberry/error.log"
  end

  test do
    if File.exist?("#{ENV["HOME"]}/awaberry/.awaberrydata/execution.log")
      puts "Log file for awaberry exists - client is up."
    else
      puts "File does not exist."
    end
  end
end
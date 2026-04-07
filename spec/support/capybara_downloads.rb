# frozen_string_literal: true

CAPYBARA_DOWNLOADS_PATH = Rails.root.join('tmp', 'capybara_downloads').freeze

Capybara.register_driver :selenium_chrome_headless_downloads do |app|
  FileUtils.mkdir_p(CAPYBARA_DOWNLOADS_PATH)

  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless=new')
  # Disables Chrome's OS-level sandbox, which restricts what the browser process can access.
  options.add_argument('--no-sandbox')
  options.add_preference('download.default_directory', CAPYBARA_DOWNLOADS_PATH.to_s)

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

module CapybaraDownloadHelpers
  def downloaded_files
    Dir[CAPYBARA_DOWNLOADS_PATH.join('*')]
  end

  def wait_for_download(timeout: 10)
    Timeout.timeout(timeout) { sleep 0.2 until downloaded_files.any? }
  rescue Timeout::Error
    raise "No file appeared in #{CAPYBARA_DOWNLOADS_PATH} within #{timeout}s"
  end

  def clear_downloads
    FileUtils.rm_f(Dir[CAPYBARA_DOWNLOADS_PATH.join('*')])
  end
end

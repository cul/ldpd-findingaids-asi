class AdminController < ApplicationController
  before_action :authenticate_user!
  helper_method :ead_cache_zip_timestamp

  # GET /admin
  def index
  end

  private

  def ead_cache_zip_timestamp
    zip_file = CONFIG[:ead_cache_zip_path]
    return nil unless File.exist?(zip_file)

    File.mtime(zip_file).strftime('%B %d, %Y at %l:%M %p')
  rescue StandardError
    nil
  end
end

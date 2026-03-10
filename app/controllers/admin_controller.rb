class AdminController < ApplicationController
  before_action :authenticate_user!
  helper_method :ead_cache_zip_info

  # GET /admin
  def index
  end

  private

  def ead_cache_zip_info
    zip_file = CONFIG[:ead_cache_zip_path]
    return nil unless File.exist?(zip_file)

    {
      timestamp: File.mtime(zip_file).strftime('%B %d, %Y at %l:%M %p'),
      size: (File.size(zip_file).to_f / 1000000).round(2).to_s + ' MB'
    }
  end
end

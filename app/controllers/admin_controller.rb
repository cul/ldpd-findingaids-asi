class AdminController < ApplicationController
  before_action :authenticate_user!
  helper_method :ead_cache_zip_timestamp

  # GET /admin
  def index
  end

  private

  def ead_cache_zip_timestamp
    zip_file = Dir.glob(File.join(CONFIG[:ead_cache_zip_dir], 'ead-cache_*.zip')).sort.last
    return nil unless zip_file

    match = File.basename(zip_file, '.zip').match(/ead-cache_(\d{14})/)
    Time.strptime(match[1], '%Y%m%d%H%M%S').strftime('%B %d, %Y at %l:%M %p') if match
  rescue ArgumentError
    nil
  end
end

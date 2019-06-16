class ApplicationController < ActionController::Base

  before_action :set_preview_flag

  private
  # @as_repo_id => repo ID in ArchiveSpace
  def validate_repository_code_and_set_repo_id
    if REPOS.key? params[:repository_id]
      @as_repo_id = REPOS[params[:repository_id]][:as_repo_id]
      @repository_name = REPOS[params[:repository_id]][:name]
    else
      Rails.logger.warn("Non-existent repo code in url")
      # for now, redirect to root. Change later
      redirect_to '/'
    end
  end

  def cached_as_ead(bib_id)
    cached_file = "tmp/as_ead_ldpd_#{bib_id}.xml"
    if File.exist?(cached_file)
      Rails.logger.warn("Cache: File #{cached_file} exists")
      open(cached_file) do |b|
        b.read
      end
    else
      Rails.logger.warn("Cache: File #{cached_file} DOES NOT exists, AS API call required")
      if CONFIG[:use_fixtures]
        as_ead = @as_api.get_ead_resource_description_from_local_fixture(@as_repo_id, @as_resource_id)
      else
        as_ead = @as_api.get_ead_resource_description(@as_repo_id, @as_resource_id)
      end
      File.open(cached_file, "wb") do |file|
        file.write(as_ead)
      end
      as_ead
    end
  end

  def preview_as_ead(bib_id)
    if CONFIG[:use_fixtures]
      Rails.logger.warn("Preview for ldpd_#{bib_id}, using fixtures")
      as_ead = @as_api.get_ead_resource_description_from_local_fixture(@as_repo_id, @as_resource_id)
    else
      Rails.logger.warn("Preview for ldpd_#{bib_id}, AS API call required with include_unpublished=true")
      as_ead = @as_api.get_ead_resource_description(@as_repo_id, @as_resource_id, true)
    end
    as_ead
  end

  def initialize_as_api
    @as_api = ArchiveSpace::Api::Client.new
  end

  def set_preview_flag
    puts request.path
    @preview_flag = request.path.start_with?('/preview')
  end
end

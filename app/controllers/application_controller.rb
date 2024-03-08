require 'open-uri'
class ApplicationController < ActionController::Base
  include Blacklight::Controller

  attr_accessor :authenticity_token

  private

  # @as_repo_id => repo ID in ArchiveSpace
  def validate_repository_code_and_set_repo_id
    @repository = Arclight::Repository.find_by(slug: params[:repository_id])
    @repository_code = @repository.id
    @as_repo_id = @repository.as_repo_id
    @repository_name = @repository.name
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.warn(e.message)
    unless params[:id].blank?
      bib_id = params[:id].delete_prefix('ldpd_')
      Rails.logger.warn("redirect to CLIO with Bib ID #{bib_id}")
      redirect_to CONFIG[:clio_redirect_url] + bib_id
    else
      Rails.logger.warn("no Bib ID in url")
      redirect_to '/'
    end
  end


end

require 'open-uri'
class ApplicationController < ActionController::Base
  include Blacklight::Controller

  attr_accessor :authenticity_token

  PREFIX_ID_CUL = 'cul-'
  PREFIX_ID_LDPD = 'ldpd_'

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
      clio_id = params[:id].delete_prefix(PREFIX_ID_LDPD)
      clio_id.sub!(PREFIX_ID_CUL, '')
      Rails.logger.warn("redirect to CLIO with Bib ID #{clio_id}")
          redirect_to (CONFIG[:clio_redirect_url] + clio_id), allow_other_host: true
    else
      Rails.logger.warn("no Bib ID in url")
      redirect_to '/'
    end
  end

  # This overrides the url that Devise redirects to after sign-in
  def after_sign_in_path
    admin_index_path
  end
end

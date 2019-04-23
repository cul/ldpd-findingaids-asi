class ApplicationController < ActionController::Base
  before_action :set_instance_var

  private
  def set_instance_var
    @as_api = ArchiveSpace::Api::Client.new
  end

  # @as_repo_id => repo ID in ArchiveSpace
  def validate_repository_code_and_set_repo_id
    if REPOS.key? params[:repository_id]
      @as_repo_id = REPOS[params[:repository_id]][:as_repo_id]
    else
      # not currently displaying contents of flash, but may be useful
      # when redirect to other than root
      flash[:error] = 'Non-existent repo code in url'
      # for now, redirect to root. Change later
      redirect_to '/'
    end
  end

  # @as_resource_id => resource ID in ArchiveSpace
  def validate_bib_id_and_set_resource_id
     bib_id = params[:id].delete_prefix('ldpd_').to_i
     puts bib_id
    if CONFIG[:use_fixtures]
      @as_resource_id = @as_api.get_resource_id_local_fixture(bib_id)
    else
      @as_respource_id = @as_api.get_resource_id(bib_id)
    end

    # not currently displaying contents of flash, but may be useful
      # when redirect to other than root
    # flash[:error] = 'Non-existent repo code in url'
      # for now, redirect to root. Change later
    # redirect_to '/'
  end
end

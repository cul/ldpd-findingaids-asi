class ApplicationController < ActionController::Base
  private
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
end

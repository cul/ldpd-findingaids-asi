class FindingAidsController < ApplicationController
  before_action :validate_repository_code_in_url

  def index
  end

  def show
  end

  private
  def validate_repository_code_in_url
    unless REPOS.key? params[:repository_id]
      # not currently displaying contents of flash, but may be useful
      # when redirect to other than root
      flash[:error] = 'Non-existent repo code in url'
      # for now, redirect to root. Change later
      redirect_to '/'
    end
  end
end

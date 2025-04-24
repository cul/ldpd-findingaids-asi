class AdminController < ApplicationController
  before_action :authenticate_user!

  # GET /admin
  def index
  end
end

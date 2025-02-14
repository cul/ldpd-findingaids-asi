class AdminController < ApplicationController
  # GET /admin
  def index
  end
  
  # POST /admin/refresh_resource
  def refresh_resource
    render json: {result: true, resource_id: 'cul-13202800'}
  end
end

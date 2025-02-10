class AdminController < ApplicationController
  # GET /admin
  def index
  end
  
  # POST /admin/refresh_resource
  def refresh_resource
    sleep 2
    render json: {result: true, resource_id: 'cul-13202800'}
  end
end

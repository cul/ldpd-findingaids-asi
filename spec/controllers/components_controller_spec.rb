require 'rails_helper'

RSpec.describe ComponentsController, type: :controller do
  # fcd1, 04/12/19: Can't figure out a way to make the following
  # work with nested resource within finding aids within repositories  
  xdescribe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  xdescribe "GET #show" do
    it "returns http success" do
      get :show
      expect(response).to have_http_status(:success)
    end
  end

end

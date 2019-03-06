require 'rails_helper'

RSpec.describe AsiController, type: :controller do

  describe "GET #as_ead_from_fixture" do
    it "returns http success" do
      get :as_ead_from_fixture
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #as_ead" do
    xit "returns http success" do
      get :as_ead
      expect(response).to have_http_status(:success)
    end
  end

end

require 'rails_helper'

RSpec.describe RepositoriesController, type: :controller do

  describe "GET #index" do
    before do
      allow(controller).to receive(:load_collection_counts).and_return({})
    end
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

end

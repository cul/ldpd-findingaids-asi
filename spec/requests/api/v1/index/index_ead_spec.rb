require 'rails_helper'
require 'acfa/index.rb'


url = "/api/v1/index/index_ead"

RSpec.describe url, type: :request do
  describe "without authentication" do
    it "returns the expected response" do
      post url
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "with authentication" do
    before do
      allow_any_instance_of(IndexEadJob).to receive(:perform).and_return(1)
      allow(Acfa::Index).to receive(:build_suggester)
    end
    it "returns the expected response" do
      post_with_auth url,
           headers: {
             'Content-Type' => 'application/json'
             },
             params: {"bibids" => ["ldpd_7746709"]}.to_json
      expect(response).to have_http_status(:success)
    end
  end
end
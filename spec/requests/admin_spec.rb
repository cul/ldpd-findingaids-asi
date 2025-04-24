require 'rails_helper'
require 'acfa/index.rb'

url = '/admin'

RSpec.describe url, type: :request do
  include Devise::Test::IntegrationHelpers

  describe "without authentication" do
    it "redirects to sign-in" do
      get url
      expect(response).to have_http_status(:found)
      expect(response.headers['Location']).to end_with('/users/sign_in')
    end
  end

  describe "with authentication" do
    before { sign_in User.new }

    it "returns a successful response" do
      get url
      expect(response).to have_http_status(:success)
    end
  end
end

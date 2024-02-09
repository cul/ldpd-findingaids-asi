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
    let(:bibids) { ['ldpd_7746709', 'ldpd_8972723'] }
    let(:index_ead_job_double) { double(IndexEadJob) }
    before do
      allow(IndexEadJob).to receive(:new).and_return(index_ead_job_double)
      bibids.each do |bibid|
        expect(index_ead_job_double).to receive(:perform).with("as_ead_#{bibid}.xml").and_return(1)
      end
      allow(Acfa::Index).to receive(:build_suggester)
    end
    it "returns the expected response" do
      post_with_auth  url,
                      headers: { 'Content-Type' => 'application/json' },
                      params: {"bibids" => bibids}.to_json
      expect(response).to have_http_status(:success)
    end
  end
end

require 'rails_helper'
require 'acfa/index.rb'

url = '/api/v1/admin/refresh_resource'

RSpec.describe url, type: :request do
  describe "without authentication" do
    it "returns the expected response" do
      post url
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "with authentication" do
    let(:repository_id) { '2' }
    let(:resource_id) { '2024' }
    let(:resource_record_uri) { "/repositories/#{repository_id}/resources/#{resource_id}" }
    let(:include_unpublished) { true }
    let(:bib_id) { '4078184' }
    let(:expected_ead_filename) { "as_ead_cul-#{bib_id}.xml" }

    before do
      mock_acfa_archivesspace_client = double('Acfa::ArchivesSpace::Client')
      allow(Acfa::ArchivesSpace::Client).to receive(:instance).and_return(mock_acfa_archivesspace_client)
      allow(mock_acfa_archivesspace_client).to receive(:bib_id_for_resource).with(resource_record_uri: resource_record_uri).and_return(bib_id)
      allow(mock_acfa_archivesspace_client).to receive(:download_ead).with(
        resource_record_uri: resource_record_uri,
        filename: expected_ead_filename,
        include_unpublished: include_unpublished
      ).and_return(bib_id)
    end

    it "returns the expected response" do
      expect(IndexEadJob).to receive(:perform_now).with(expected_ead_filename)
      post_with_auth  url,
                      headers: { 'Content-Type' => 'application/json' },
                      params: { 'resource_record_uri' => resource_record_uri, 'include_unpublished' => include_unpublished}.to_json
      expect(response).to have_http_status(:success)
      expect(response.body).to eq(
        { result: true, resource_id: 'cul-4078184' }.to_json
      )
    end
  end
end

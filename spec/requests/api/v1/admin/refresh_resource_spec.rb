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

    it "performs the expected set of actions and returns the expected response during a successful operation" do
      expect(IndexEadJob).to receive(:perform_now).with(expected_ead_filename)
      post_with_auth(
        url,
        headers: { 'Content-Type' => 'application/json' },
        params: { 'resource_record_uri' => resource_record_uri, 'include_unpublished' => include_unpublished}.to_json
      )
      expect(response).to have_http_status(:success)
      expect(response.body).to eq(
        { result: true, resource_id: 'cul-4078184' }.to_json
      )
    end

    context "error responses" do
      exceptions_and_expected_responses = [
        [
          Net::ReadTimeout.new,
          { result: false, error: 'ArchivesSpace EAD download took too long and the request timed out.' }
        ],
        [
          Acfa::Exceptions::InvalidArchivesSpaceResourceUri.new('error message 1'),
          { result: false, error: 'error message 1' }
        ],
        [
          Acfa::Exceptions::InvalidEadXml.new('error message 2'),
          { result: false, error: 'error message 2' }
        ],
        [
          Acfa::Exceptions::UnexpectedArchivesSpaceApiResponse.new('error message 3'),
          { result: false, error: 'error message 3' }
        ],
        [
          ArchivesSpace::ConnectionError.new,
          { result: false, error: 'Unable to connect to ArchivesSpace.' }
        ]
      ]

      exceptions_and_expected_responses.each do |exception, expected_response|
        context "when an exception of type #{exception.class.name} is raised" do
          before do
            allow(Acfa::ArchivesSpace::Client.instance).to receive(:bib_id_for_resource).and_raise(exception)
            post_with_auth(
              url,
              headers: { 'Content-Type' => 'application/json' },
              params: { 'resource_record_uri' => resource_record_uri, 'include_unpublished' => include_unpublished}.to_json
            )
          end

          it "responds with the expected status and response" do
            expect(response).to have_http_status(:internal_server_error)
            expect(response.body).to eq(expected_response.to_json)
          end
        end
      end
    end
  end
end

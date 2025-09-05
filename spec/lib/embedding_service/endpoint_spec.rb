require "rails_helper"

RSpec.describe EmbeddingService::Endpoint do
  describe "#construct_endpoint_uri" do
    let(:destination_host) { 'vector-embedding-endpoint' }
    let(:destination_url) { "https://#{destination_host}" }
    let(:model_details) do
        {
            namespace: 'BAAI',
            model: 'bge_base_en_15',
            dimensions: 768,
            summarize: false
        }
    end
    let(:expected_params) do
        {
            "namespace" => "BAAI",
            "model" => "bge_base_en_15",
            "dimensions" => "768",
            "summarize" => "false"
        }
    end

    it 'constructs the expected url' do
        url = described_class.construct_endpoint_url(destination_url, model_details)
        params = Rack::Utils.parse_nested_query(url.query)
        expect(url.host).to eq(destination_host)
        expect(params).to eq(expected_params)
    end
  end
end
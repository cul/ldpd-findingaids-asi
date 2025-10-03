require "rails_helper"

RSpec.describe EmbeddingService::Endpoint do
  let(:destination_host) { 'vector-embedding-endpoint' }
  let(:destination_url) { "https://#{destination_host}" }
  let(:field_value) { "test input" }
    let(:model_details) do
        {
            namespace: 'BAAI',
            model: 'bge-base-en-v1.5',
            dimensions: 768,
            summarize: false
        }
    end


  describe "#generate_vector_embedding" do
      before do
          allow_any_instance_of(Net::HTTP).to receive(:request).and_raise(Timeout::Error, "connection closed")
      end  
      it "raises errors thrown by embedding service" do
          expect {
              described_class.generate_vector_embedding(destination_url, model_details, field_value)
          }.to raise_error(EmbeddingService::GenerationError) { |error|
              expect(error.message).to include("Embedding failed for")          
              expect(error.cause).to be_a(Timeout::Error)
              expect(error.cause.message).to eq("connection closed")
          }
      end
  end

  describe "#create_params" do
    let(:expected_params) do
        {
            model: "BAAI/bge-base-en-v1.5",
            summarize: "false",
            text: field_value
        }
    end

    it 'constructs the expected params' do
        params = described_class.create_params(model_details, field_value)
        expect(params).to eq(expected_params)
    end
  end
end
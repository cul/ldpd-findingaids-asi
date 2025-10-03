require 'rails_helper'

describe SearchBuilder do
  let(:test_query) { "test query" }
  let(:user_params) { { q: test_query, vector_search: 'true' } }
  let(:blacklight_config) { Blacklight::Configuration.new }
  let(:scope) { double blacklight_config: blacklight_config }
  let(:search_builder) { described_class.new(scope) }
  let(:fake_embedding)    { [0.1, 0.2, 0.3] }

  before do
    allow(EmbeddingService::Embedder)
      .to receive(:convert_text_to_vector_embedding)
      .and_return(fake_embedding)

    controller_double = double(
      action_name: 'hierarchy',
      params: { id: '123' }
    )
    allow_any_instance_of(Blacklight::SearchState)
      .to receive(:controller)
      .and_return(controller_double)
  end

  describe "no vector search" do
    let(:no_vec_params) { { q: test_query} }
    let(:query_parameters) { search_builder.with(no_vec_params).processed_parameters }
    it 'includes the user submitted params' do
      expect(query_parameters[:q]).to eq test_query
    end
  end


  describe "vector search" do
    let(:query_string) { search_builder.with(user_params).processed_parameters[:q] }

    it 'replaces the text query with a query that embeds the vector' do
      expect(query_string).not_to eq(test_query)
      expect(query_string).to include("[#{fake_embedding.join(', ')}]")
      expect(query_string).to start_with('{!')
    end

  end
end

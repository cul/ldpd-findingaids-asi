require 'rails_helper'

describe SearchBuilder do
  let(:test_query) { "test query" }
  let(:blacklight_config) { Blacklight::Configuration.new }
  let(:scope) { double blacklight_config: blacklight_config }
  let(:search_builder) { described_class.new(scope) }
  let(:fake_embedding)    { [0.1, 0.2, 0.3] }

  before do
    allow(EmbeddingService::Endpoint)
      .to receive(:generate_vector_embedding)
      .and_return(fake_embedding)

    allow(EmbeddingService::CachedEmbedder)
      .to receive(:get_endpoint_params)
      .and_return({ dimensions: 768 })

    controller_double = double(
      action_name: 'hierarchy',
      params: { id: '123' }
    )
    allow_any_instance_of(Blacklight::SearchState)
      .to receive(:controller)
      .and_return(controller_double)
  end

  describe 'behavior driven by search mode' do
    shared_examples 'vector search is executed' do
      it 'converts the query to the embedding syntax' do
        expect(processed_params[:q]).not_to eq(test_query)
        expect(processed_params[:q]).to include("[#{fake_embedding.join(', ')}]")
        expect(processed_params[:q]).to start_with('{!')
      end
    end

    shared_examples 'standard search is executed' do
      it 'does not alter query' do
        expect(processed_params[:q]).to eq(test_query)
      end
    end

    context "when default_search is 'standard'" do
      before do
        allow(CONFIG).to receive(:[]).and_call_original
        allow(CONFIG).to receive(:[]).with(:default_search_mode).and_return('standard')
      end

      context 'and no vector_search param is supplied' do
        let(:processed_params) { search_builder.with(q: test_query).processed_parameters }
        include_examples 'standard search is executed'
      end

      context "and vector_search param is supplied" do
        let(:processed_params) do
          search_builder.with(q: test_query, vector_search: 'model_name').processed_parameters
        end
        include_examples 'vector search is executed'
      end
    end

    context "when default_search is 'vector'" do
      before do
        allow(CONFIG).to receive(:[]).and_call_original
        allow(CONFIG).to receive(:[]).with(:default_search_mode).and_return('vector')
      end

      # context 'and no query parameter is supplied' do
      #   let(:test_query) { "" }
      #   let(:processed_params) { search_builder.with(q: test_query).processed_parameters }
      #   include_examples 'standard search is executed'
      # end

      context 'and no vector_search param is supplied' do
        let(:processed_params) { search_builder.with(q: test_query).processed_parameters }
        include_examples 'vector search is executed'
      end

      context "and vector_search param is supplied" do
        let(:processed_params) do
          search_builder.with(q: test_query, vector_search: 'model_name').processed_parameters
        end
        include_examples 'vector search is executed'
      end
    end
  end

  describe '#vector_search_enabled?' do
    subject { search_builder.vector_search_enabled? }

    before do
      allow(search_builder).to receive(:blacklight_params).and_return(override_params)
      stub_const('CONFIG', { default_search_mode: default_mode })
    end

    context 'when override parameter is provided' do
      context 'override is "true"' do
        let(:override_params) { { vector_search: 'model_name' } }
        let(:default_mode)    { 'standard' }

        it { is_expected.to be true }
      end
    end

    context 'when no override parameter is provided' do
      let(:override_params) { {} }

      context 'and default_search_mode is "vector"' do
        let(:default_mode) { 'vector' }

        it { is_expected.to be true }
      end

      context 'and default_search_mode is "standard"' do
        let(:default_mode) { 'standard' }

        it { is_expected.to be false }
      end
    end
  end
end

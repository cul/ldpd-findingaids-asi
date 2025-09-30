require 'rails_helper'

RSpec.describe IndexEadJob do
  let(:index_ead_job) { described_class.new }
  let(:mock_writer) { instance_double(Traject::SolrJsonWriter) }

  describe '#perform' do
    before do
      # Point CONFIG to the fixture directory
      CONFIG[:ead_cache_dir] = File.join(file_fixture_path, 'ead')
      allow_any_instance_of(Traject::Indexer::NokogiriIndexer).to receive(:writer).and_return(mock_writer)
      allow_any_instance_of(Traject::Indexer::NokogiriIndexer).to receive(:complete)
      allow(mock_writer).to receive(:put)
      allow(mock_writer).to receive(:commit)
    end

    context 'with valid collection' do
      let(:filename) { 'test_ead.xml' }

      it 'indexes successfully when no nested collections are present' do
        result = index_ead_job.perform(filename)

        expect(mock_writer).to have_received(:put).once
        expect(mock_writer).to have_received(:commit).once
        expect(result[:indexed]).to eq(1)
        expect(result[:errors]).to eq(0)
        expect(result[:skip_messages]).to be_empty
      end
    end

    context 'with nested collection' do
      let(:filename) { 'test_nested_collection_exception.xml' }

      it 'skips the entire file when nested collection is detected' do
        result = index_ead_job.perform(filename)

        expect(mock_writer).not_to have_received(:put)
        expect(mock_writer).not_to have_received(:commit)
        expect(result[:indexed]).to eq(0)
        expect(result[:errors]).to eq(1)
        expect(result[:skip_messages]).to include("Detected nested collection components")
      end
    end
  end
end

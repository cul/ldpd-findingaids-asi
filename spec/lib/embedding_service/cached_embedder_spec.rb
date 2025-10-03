require "rails_helper"

RSpec.describe EmbeddingService::CachedEmbedder do
  describe "#convert_text_to_vector_embedding" do
    let(:searchable_text) { "example descriptive text" }
    let(:dimension) { "768" }
    let(:model_identifier) { "bge_base_en_15_#{dimension}" }
    let(:hash)            { Zlib.crc32(searchable_text) }
    let(:doc_id)          { "/123/example" }
    let(:new_embedding) { Array.new(768) { rand(-1.0..1.0).round(6) } }


    let(:cached_768)  { Array.new(768)  { rand(-1.0..1.0).round(6) } }
    let(:cached_1024) { Array.new(1024) { rand(-1.0..1.0).round(6) } }

    context "when required arguments are nil" do
      it "raises an error when doc_id is nil" do
        expect {
          described_class.convert_text_to_vector_embedding(nil, searchable_text, model_identifier)
        }.to raise_error(ArgumentError, /doc_id cannot be nil/)
      end

      it "raises an error when multiple arguments are nil" do
        expect {
          described_class.convert_text_to_vector_embedding(doc_id, nil, nil)
        }.to raise_error(ArgumentError, /field_value, model_identifier cannot be nil/)
      end
    end

    context "when a row does not exist in the cache table" do
      before do
        allow(EmbeddingService::Endpoint).to receive(:generate_vector_embedding)
          .and_return(Array.new(768)  { rand(-1.0..1.0).round(6) })
      end

      let(:embedding) do
         described_class.convert_text_to_vector_embedding(
          doc_id,
          searchable_text,
          model_identifier
        )
      end

      let(:cache_row){ EmbeddingCache.find_by(doc_id: doc_id) }

      it "calls the embedding service" do
        embedding
        expect(EmbeddingService::Endpoint).to have_received(:generate_vector_embedding).once
      end

      it "creates a cache row" do
        expect(EmbeddingCache.where(doc_id: doc_id)).not_to exist
        embedding
        expect(cache_row).to be_present
      end

      it "stores the correct values in the cache row" do
        embedding
        expect(cache_row.value_hash).to eq(hash)
        expect(cache_row.bge_base_en_15_768).to eq(embedding)
      end
    end

    context "when a row already exists in the cache table" do
      let!(:cache_row) do
        EmbeddingCache.create!(
          doc_id:          doc_id,
          value_hash: hash,
          bge_base_en_15_768: cached_768,
          bge_base_en_15_1024: cached_1024
        )
      end

      context "when the document's searchable_text hash has a match in the cache" do
          it "returns the expected cached embedding and does not call the embedding service" do
            expect(EmbeddingService::Endpoint).not_to receive(:generate_vector_embedding)

            embedding = described_class.convert_text_to_vector_embedding(doc_id, searchable_text, model_identifier)

            expect(embedding).to eq(cached_768)
          end
      end

      context "when the document's searchable_text hash does not match the value in the cache" do
        let(:new_text) { "searchable text that has changed" }
        before do
          allow(EmbeddingService::Endpoint).to receive(:generate_vector_embedding).and_return(new_embedding)
        end
        it "refreshes the cache" do
          embedding =  described_class.convert_text_to_vector_embedding(doc_id, new_text, model_identifier)

          expect(EmbeddingService::Endpoint).to have_received(:generate_vector_embedding).once
          expect(embedding).to eq(new_embedding)
          updated_hash = EmbeddingCache.where(doc_id: doc_id).pluck(:value_hash).first
          expect(updated_hash).not_to eq(hash)
        end
      end
    end
  end
end
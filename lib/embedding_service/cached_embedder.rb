module EmbeddingService
  class CachedEmbedder

      MODEL_MAPPING = {
        'bge_base_en_15_768' => {
            embedding_cache_column: 'bge_base_en_15_768',
            vector_embedding_app: {
                namespace: 'BAAI',
                model: 'bge_base_en_15',
                dimensions: 768,
                summarize: false
            }
        },
        'bge_base_en_15_1024' => {
            embedding_cache_column: 'bge_base_en_15_1024',
            vector_embedding_app: {
                namespace: 'BAAI',
                model: 'bge_base_en_15',
                dimensions: 1024,
                summarize: false
            }
        }
    }.freeze


    def self.convert_text_to_vector_embedding(doc_id, field_value, model_identifier)
        mapping = MODEL_MAPPING[ model_identifier]
        cached_embedding = cached_vector(doc_id, field_value, mapping[:embedding_cache_column])
        cached_embedding ? cached_embedding : update_cache(doc_id, mapping[:vector_embedding_app], field_value)
    end

    def self.update_cache(doc_id, model_details, field_value)
        new_hash =   Zlib.crc32(field_value)
        new_embedding = EmbeddingService::Endpoint.generate_vector_embedding(CONFIG[:embedding_service_base_url], model_details, field_value)

        EmbeddingCache.find_or_create_by(doc_id: doc_id).update(
            value_hash: new_hash,
            bge_base_en_15_768: new_embedding
        )

        new_embedding
    end

    def self.cached_vector(doc_id, field_value, key_column)
        value_hash = Zlib.crc32(field_value)
        record = EmbeddingCache.find_by(doc_id: doc_id, value_hash: value_hash)
        record ? record[key_column] : nil
    end

  end
end
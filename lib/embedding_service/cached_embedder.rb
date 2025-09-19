module EmbeddingService
  class CachedEmbedder

      MODEL_MAPPING = {
        'bge_base_en_15_768' => {
            namespace: 'BAAI',
            model: 'bge-base-en-v1.5',
            dimensions: 768,
            summarize: false
        },
        'bge_base_en_15_1024' => {
            namespace: 'BAAI',
            model: 'bge-large-en-v1.5',
            dimensions: 1024,
            summarize: false
        }
    }.freeze


    def self.convert_text_to_vector_embedding(doc_id, field_value, model_identifier)
        nil_arguments = []
        nil_arguments << "doc_id" if doc_id.nil?
        nil_arguments << "field_value" if field_value.nil?
        nil_arguments << "model_identifier" if model_identifier.nil?

        unless nil_arguments.empty?
            raise ArgumentError, "#{nil_arguments.join(', ')} cannot be nil."
        end

        cached_embedding = cached_vector(doc_id, field_value, model_identifier)
        cached_embedding ? cached_embedding : update_cache(doc_id, field_value, model_identifier)
    end

    def self.update_cache(doc_id, field_value, model_identifier)
        new_hash =   Zlib.crc32(field_value)
        endpoint_params = get_endpoint_params(model_identifier)
        new_embedding = EmbeddingService::Endpoint.generate_vector_embedding(CONFIG[:embedding_service_base_url], endpoint_params, field_value)

        EmbeddingCache.find_or_create_by(doc_id: doc_id, model_identifier: model_identifier).update(
            {
                value_hash: new_hash,
                embedding: new_embedding
            }
        )

        new_embedding
    end

    def self.get_endpoint_params(model_identifier)
        MODEL_MAPPING[model_identifier]
    end

    def self.cached_vector(doc_id, field_value, model_identifier)
        value_hash = Zlib.crc32(field_value)
        record = EmbeddingCache.find_by(doc_id: doc_id, model_identifier: model_identifier, value_hash: value_hash)
        record ? record.embedding : nil
    end

  end
end
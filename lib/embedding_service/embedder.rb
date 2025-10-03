module EmbeddingService
  class Embedder
    def self.convert_text_to_vector_embedding(field_value)

        uri = URI('https://vector-embeddings-dev.library.columbia.edu/vectorize/BAAI/bge-base-en-v1.5')
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        request = Net::HTTP::Post.new(uri)
        puts "emb:"
        puts field_value[0, 2000]
        # request.body = "text=#{field_value}"
        request.body = "text=#{field_value[0, 1000]}"
        request['Content-Type'] = 'application/x-www-form-urlencoded'

        begin
            response = http.request(request)
            parsed_response = ::JSON.parse(response.body)
            if parsed_response['embeddings']
                Rails.logger.debug { "Embedding generated successfully for text (first 20 chars): #{field_value.truncate(20)}" }
                return parsed_response['embeddings']
            else
                Rails.logger.warn { "Embedding service returned no embeddings for: #{field_value.truncate(20)}" }
                return nil
            end
        rescue StandardError => e
            Rails.logger.error { "Error generating embedding for: #{field_value.truncate(20)} -- #{e.class}: #{e.message}" }
            return nil
        end
    end
  end
end

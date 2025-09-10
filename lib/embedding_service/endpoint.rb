module EmbeddingService
  class Endpoint
    def self.generate_vector_embedding(destination_url, model_details, field_value)
        uri = URI(destination_url)
        model_params = parameterize_model_details(model_details)
        uri.query = URI.encode_www_form(model_params)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri  .to_s.start_with?('https:') ? true : false

        request = Net::HTTP::Post.new(uri)
        request.body = prepare_value_parameter(field_value)
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
            raise EmbeddingService::GenerationError.new("Embedding failed for '#{field_value.truncate(20)}'"), cause: e
        end
    end

    def self.parameterize_model_details(model_details)
        endpoint_values = model_details[:vector_embedding_app]
        {
            model: "#{endpoint_values[:namespace]}/#{endpoint_values[:model]}",
            summarize: "#{endpoint_values[:summarize]}"
        }
    end

    def self.prepare_value_parameter(field_value)
        "text=#{field_value[0, 512]}"
    end
  end
end

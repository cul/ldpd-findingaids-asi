module EmbeddingService
  class Endpoint
    def self.generate_vector_embedding(destination_url, model_details, field_value)
        uri = URI("#{destination_url}/vectorize")
        params = create_params(model_details, field_value)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.to_s.start_with?('https:')

        request = Net::HTTP::Post.new(uri)
        request['Content-Type'] = 'application/x-www-form-urlencoded'
        request.set_form_data(params)

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

    def self.create_params(model_details, field_value)
        {
            model: "#{model_details[:namespace]}/#{model_details[:model]}",
            summarize: "#{model_details[:summarize]}",
            text: truncate_value(field_value) 
        }
    end

    def self.truncate_value(field_value)
        field_value[0, 512]
    end
  end
end

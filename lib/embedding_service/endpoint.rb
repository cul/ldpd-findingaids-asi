module EmbeddingService
  class Endpoint
    def self.generate_vector_embedding(destination_url, model_details, field_value)
        uri = construct_endpoint_url(destination_url, model_details)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = CONFIG[:embedding_service_base_url]&.start_with?('https:') ? true : false

        request = Net::HTTP::Post.new(uri)
        request.body = prepare_value_parameter(field_value)
        request['Content-Type'] = 'application/x-www-form-urlencoded'

        # begin
        #     response = http.request(request)
        #     parsed_response = ::JSON.parse(response.body)
        #     if parsed_response['embeddings']
        #         Rails.logger.debug { "Embedding generated successfully for text (first 20 chars): #{field_value.truncate(20)}" }
        #         return parsed_response['embeddings']
        #     else
        #         Rails.logger.warn { "Embedding service returned no embeddings for: #{field_value.truncate(20)}" }
        #         return nil
        #     end
        # rescue StandardError => e
        #     Rails.logger.error { "Error generating embedding for: #{field_value.truncate(20)} -- #{e.class}: #{e.message}" }
        #     return nil
        # end
    end

    def self.construct_endpoint_url(destination_url, model_details)
        param_string = URI.encode_www_form(model_details)
        uri = URI("#{destination_url}?#{param_string}")
    end

    def self.prepare_value_parameter(field_value)
        "text=#{field_value[0, 512]}"
    end
  end
end

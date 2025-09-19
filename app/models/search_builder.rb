# frozen_string_literal: true

# NOTE: This class is NOT automatically reloaded when doing local development,
# so you'll need to restart your Rails server whenever you make changes.
class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include BlacklightRangeLimit::RangeLimitBuilder

  include Arclight::SearchBehavior

  self.default_processor_chain += [:convert_query_to_embedding_for_vector_search]

  def add_hierarchy_behavior(solr_parameters)
    return unless search_state.controller&.action_name == 'hierarchy'
    request_id = search_state.controller.params[:id]
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "_nest_parent_:#{blacklight_params[:id] || request_id}"
    solr_parameters[:rows] = blacklight_params[:per_page]&.to_i || blacklight_params[:limit]&.to_i || 999_999_999
    solr_parameters[:start] = blacklight_params[:offset] if blacklight_params[:offset]
    solr_parameters[:sort] = 'sort_isi asc'
    solr_parameters[:facet] = false
    #solr_parameters[:group] = false # explicitly ungroup in case it was defaulted
  end
  ##
  # @example Adding a new step to the processor chain
  #   self.default_processor_chain += [:add_custom_data_to_query]
  #
  #   def add_custom_data_to_query(solr_parameters)
  #     solr_parameters[:custom] = blacklight_params[:user_value]
  #   end

  def sort
    return search_state.sort_field&.sort unless search_state.sort_field && search_state.params[:group].to_s == 'true'

    return "#{search_state.sort_field.group_under}, #{search_state.sort_field.sort}" if search_state.sort_field.group_under

    search_state.sort_field.sort
  end

  def convert_query_to_embedding_for_vector_search(solr_parameters)
    return unless vector_search_enabled? && blacklight_params[:q].present?

    default_search_handler = 'select'
    vector_search_handler = 'select-vector'

    blacklight_config.solr_path = vector_search_handler

    query_text = blacklight_params[:q]

    model_identifier = get_model_identifier(blacklight_params)

    endpoint_params = EmbeddingService::CachedEmbedder.get_endpoint_params(model_identifier)
    query_vector = EmbeddingService::Endpoint.generate_vector_embedding(
      CONFIG[:embedding_service_base_url],
      endpoint_params,
      query_text
    )

    if query_vector.nil?
      error_message = 'The vector embedding service is unreachable right now, so vector search will not work.'
      Rails.logger.error(error_message)
      raise RuntimeError, error_message
    end

    # Vector embedding service returned embedding data.  Replace query with vector version.
    # solr_parameters[:q] = "{!knn f=searchable_text_vector768i topK=9999}[#{query_vector.join(', ')}]"
    dimension = endpoint_params[:dimensions]
    solr_parameters[:q] = "{!vectorSimilarity f=searchable_text_vector#{dimension}i minReturn=0.79}[#{query_vector.join(', ')}]"
  end

  def vector_search_enabled?
    return true if  blacklight_params[:vector_search].present?
    CONFIG[:default_search_mode] == 'vector'
  end

  def get_model_identifier(params)
    if params[:vector_search]
      model_identifier = params[:vector_search]
    else
      model_identifier = CONFIG[:vector_search_query_key]
    end
  end
end

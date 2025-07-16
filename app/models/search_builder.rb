# frozen_string_literal: true
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
    return unless blacklight_params[:vector_search] && blacklight_params[:q].present?

    query_text = blacklight_params[:q]
    query_vector = EmbeddingService::Embedder.convert_text_to_vector_embedding(query_text)
    solr_parameters[:q] = "{!knn f=scopecontent_vector768i topK=10}[#{query_vector.join(', ')}]"
   end
end

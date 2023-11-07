# frozen_string_literal: true
class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include BlacklightRangeLimit::RangeLimitBuilder

  include Arclight::SearchBehavior

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
end

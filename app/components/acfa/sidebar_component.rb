# frozen_string_literal: true

module Acfa
  # A sidebar with collection context widget and tools
  class SidebarComponent < ::Arclight::SidebarComponent
    def collection_name
      @collection_name ||= Array(controller.params.dig(:f, :collection)).reject(&:empty?).first ||
                           helpers.current_context_document&.collection_name
    end
    
    def repository_id
      controller.params[:repository_id]
    end
    
    def render_search_bar
      sb = Acfa::SearchBarComponent.new(url: helpers.search_action_url, params: {repository_id: repository_id, f: {collection: [collection_name]}})
      sb.with_search_button do
        '<button class="btn btn-primary search-btn" type="submit" id="search"><span class="visually-hidden-sm me-sm-1 submit-search-text">Search</span><i class="fa-solid fa-magnifying-glass-location"></i></button>'.html_safe
      end
      render sb
    end
  end
end
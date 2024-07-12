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
  end
end
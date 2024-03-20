# frozen_string_literal: true

module Acfa::Arclight
  # A sidebar with collection context widget and tools
  class SidebarComponent < Arclight::SidebarComponent
    delegate :blacklight_config, :document_presenter, :should_render_field?,
             :turbo_frame_tag, to: :helpers

    def collection_context
      render Acfa::Arclight::CollectionContextComponent.new(presenter: document_presenter(document), download_component: Arclight::DocumentDownloadComponent)
    end

  end
end

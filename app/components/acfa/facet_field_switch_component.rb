# frozen_string_literal: true

module Acfa
  # Render the masthead
  class FacetFieldSwitchComponent < ::Blacklight::FacetFieldListComponent
    def initialize(facet_field:, layout: nil)
      super
      @layout = Acfa::FacetFieldSwitch::LayoutComponent
    end
  end
end

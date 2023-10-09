# frozen_string_literal: true

module Acfa
  # Render the masthead
  class MastheadComponent < ::Arclight::MastheadComponent
    def main_menu
      render Acfa::TopNavbarComponent.new(blacklight_config: @blacklight_config)
    end
  end
end

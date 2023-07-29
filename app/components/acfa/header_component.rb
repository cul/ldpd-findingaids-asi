# frozen_string_literal: true

module Acfa
  class HeaderComponent < Arclight::HeaderComponent
    def top_bar
      render Acfa::TopNavbarComponent.new(blacklight_config: blacklight_config)
    end
  end
end

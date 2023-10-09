# frozen_string_literal: true

module Acfa
  class HeaderComponent < ::Arclight::HeaderComponent
    def masthead
      render Acfa::MastheadComponent.new
    end

    def search_bar
      render Acfa::SearchNavbarComponent.new(blacklight_config: blacklight_config)
    end

    def top_bar
      render Acfa::TopNavbarComponent.new(blacklight_config: blacklight_config)
    end
  end
end

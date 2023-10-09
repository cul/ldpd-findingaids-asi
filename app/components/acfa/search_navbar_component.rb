# frozen_string_literal: true

module Acfa
  class SearchNavbarComponent < Blacklight::SearchNavbarComponent
    def initialize(blacklight_config:)
      @blacklight_config = blacklight_config
    end
  end
end
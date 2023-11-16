# frozen_string_literal: true

module Acfa::Ead::Components
  class SeriesComponent < Blacklight::Component
    attr_reader :series, :component_id, :repository, :parser

    delegate :remove_unittitle_tags, to: :helpers

    def initialize(series:, parser:, repository:, aeon_enabled: false, component_id: nil)
      @series = series
      @parser = parser
      @repository = repository
      @aeon_enabled = aeon_enabled
      @component_id = component_id
    end

    def aeon_enabled?
      @aeon_enabled
    end
  end
end

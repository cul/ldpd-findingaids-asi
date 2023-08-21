# frozen_string_literal: true

module Acfa::ControlAccess
  class FieldRowsComponent < Blacklight::Component
    def initialize(field_name:, label:, terms: nil, print_view: false)
      @field_name = field_name
      @label = label
      @terms = terms
      @print_view = print_view
    end
    def render?
      @terms.present?
    end
  end
end

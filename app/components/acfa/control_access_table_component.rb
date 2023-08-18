# frozen_string_literal: true

module Acfa
  class ControlAccessTableComponent < Blacklight::Component
    def initialize(genres: nil, names: nil, places: nil, subjects: nil, print_view: false)
      @genres_forms = genres
      @name_terms = names
      @place_terms = places
      @subjects = subjects
      @print_view = print_view
    end

    def render?
      @genres_forms.present? || @name_terms.present? || @place_terms.present? || @subjects.present?
    end
  end
end

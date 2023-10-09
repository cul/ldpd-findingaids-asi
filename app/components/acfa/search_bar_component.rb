# frozen_string_literal: true

module Acfa
  class SearchBarComponent < ::Arclight::SearchBarComponent
    def initialize(**kwargs)
      super

      (@kwargs[:form_options] ||= {})
      (@kwargs[:form_options][:html] ||=  {})[:id] = 'hero-search-form'
      (@kwargs[:classes] ||= ['search-query-form']) << 'd-flex'
    end
  end
end

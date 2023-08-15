# frozen_string_literal: true

module Acfa::Arclight
  # Render the breadcrumbs for a search result document
  class SearchResultBreadcrumbsComponent < ::Arclight::SearchResultBreadcrumbsComponent
    def breadcrumbs
      offset = grouped? ? 2 : 0

      Acfa::Arclight::BreadcrumbComponent.new(document: document, count: breadcrumb_count, offset: offset)
    end
  end
end
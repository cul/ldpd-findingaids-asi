# frozen_string_literal: true

module Acfa::Arclight
  # Display the document hierarchy as "breadcrumbs"
  class BreadcrumbComponent < Arclight::BreadcrumbComponent
    # @param [Integer] count if provided the number of bookmarks is limited to this number

    
    def build_repository_link
      render Acfa::Arclight::RepositoryBreadcrumbComponent.new(document: @document)
    end
  end
end
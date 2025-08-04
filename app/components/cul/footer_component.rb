# frozen_string_literal: true

module Cul
  class FooterComponent < ViewComponent::Base
    def initialize(repositories: Arclight::Repository.all, current_repository_slug: nil)
      @repositories = repositories
      @current_repository_slug = current_repository_slug || 'nnc'
    end
  end
end
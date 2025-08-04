# frozen_string_literal: true

module Cul::Footer
  class ContactComponent < ViewComponent::Base
    delegate :link_to_repository_location, to: :helpers

    def initialize(repositories:, current_repository_slug: nil)
      @repositories = repositories
      @repository = repositories.find { |repo| repo.slug == current_repository_slug }
    end
  end
end
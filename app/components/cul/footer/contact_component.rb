# frozen_string_literal: true

module Cul::Footer
  class ContactComponent < ViewComponent::Base
    delegate :link_to_repository_location, to: :helpers

    def initialize(current_repository_slug:)
      @repositories = Arclight::Repository.all
      @repository = @repositories.find { |repo| repo.slug == current_repository_slug } || @repositories.first
    end
  end
end
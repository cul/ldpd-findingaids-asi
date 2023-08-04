# frozen_string_literal: true

module Cul::Footer
  class ContactComponent < ViewComponent::Base
    def initialize(repository:)
      @repository = repository
    end
    def contact_links
      @repository.contact&.fetch('links', nil) || []
    end
  end
end
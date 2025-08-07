# frozen_string_literal: true

module Cul
  class FooterComponent < ViewComponent::Base
    def initialize(current_repository_slug: 'nnc')
      @current_repository_slug = current_repository_slug
    end
  end
end
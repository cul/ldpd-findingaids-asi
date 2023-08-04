# frozen_string_literal: true

module Cul
  class FooterComponent < ViewComponent::Base
    def initialize(repository: Arclight::Repository.find_by(slug: 'nnc'))
      @repository = repository
    end
  end
end

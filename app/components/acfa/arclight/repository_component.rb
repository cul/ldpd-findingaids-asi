# frozen_string_literal: true

module Acfa::Arclight
  class RepositoryComponent < ViewComponent::Base
  	delegate :arclight_engine, to: :helpers
  	attr_accessor :repository

    def initialize(repository:)
    	@repository = (Arclight::Repository === repository) ? repository : Arclight::Repository.find_by(slug: repository.id)
    end
  end
end

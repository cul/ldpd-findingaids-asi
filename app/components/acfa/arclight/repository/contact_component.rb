# frozen_string_literal: true

module Acfa::Arclight::Repository
  class ContactComponent < ViewComponent::Base
  	attr_accessor :repository

    def initialize(repository:)
    	@repository = (Arclight::Repository === repository) ? repository : Arclight::Repository.find_by(slug: repository.id)
    end
  end
end

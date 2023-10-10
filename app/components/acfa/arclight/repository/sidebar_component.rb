# frozen_string_literal: true

module Acfa::Arclight::Repository
  class SidebarComponent < ViewComponent::Base
  	attr_accessor :repository

    def initialize(repository:, classes: ['col-sm-4'])
    	@repository = (Arclight::Repository === repository) ? repository : Arclight::Repository.find_by(slug: repository.id)
      @class_attr = Array(classes).join(' ')
    end
  end
end

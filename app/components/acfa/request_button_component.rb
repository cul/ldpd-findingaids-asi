# frozen_string_literal: true

class Acfa::RequestButtonComponent < ViewComponent::Base
  attr_accessor :document

  def initialize(document)
    @document = document
  end
end

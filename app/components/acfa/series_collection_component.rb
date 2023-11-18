# frozen_string_literal: true

class Acfa::SeriesCollectionComponent < ViewComponent::Base
  renders_many :series_resources, Acfa::Ead::Components::SeriesComponent

  attr_reader :repository

  def initialize(repository:, **_args)
    super
    @repository = repository
  end
end

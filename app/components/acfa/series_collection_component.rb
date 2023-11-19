# frozen_string_literal: true

class Acfa::SeriesCollectionComponent < ViewComponent::Base
  renders_many :series_resources, Acfa::Ead::Components::SeriesComponent

  attr_reader :repository

  def initialize(repository:, finding_aid_title:, **_args)
    super
    @finding_aid_title = finding_aid_title
    @repository = repository
  end
end

# frozen_string_literal: true

class Acfa::BannerComponent < ViewComponent::Base
  delegate :arclight_engine, to: :helpers
  attr_accessor :repository

  def initialize(repository: nil, render_repository: true)
    if repository
    	@repository = (Arclight::Repository === repository) ? repository : Arclight::Repository.find_by(slug: repository.id)
    end
    @render_repository = render_repository
  end
  def render_repository?
    @repository && @render_repository
  end
end

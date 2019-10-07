class RepositoriesController < ApplicationController
  def index
  	@repositories = Repository.all.select { |repo| repo.finding_aids.present? }
  end
end

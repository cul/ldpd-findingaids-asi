class RepositoriesController < ApplicationController
  def index
    @repositories = Repository.all.select { |repo| repo.has_fa_list? }
  end
end

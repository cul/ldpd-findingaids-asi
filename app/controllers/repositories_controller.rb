class RepositoriesController < Arclight::RepositoriesController
  def index
    @repositories = Arclight::Repository.all.reject { |repo| repo.exclude_from_home? }
    load_collection_counts
  end
end

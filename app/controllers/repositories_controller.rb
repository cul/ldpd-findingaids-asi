class RepositoriesController < Arclight::RepositoriesController
  def index
    @repositories = Arclight::Repository.all.select { |repo| repo.has_fa_list? }
    load_collection_counts
  end
end

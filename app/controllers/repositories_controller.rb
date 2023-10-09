class RepositoriesController < Arclight::RepositoriesController
  def index
    @repositories = Arclight::Repository.all.select { |repo| ::Repository.find(repo.id)&.has_fa_list? }
    load_collection_counts
  end
end

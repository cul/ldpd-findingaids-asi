module RepositoriesHelper
  def repository_label(code_value)
    Arclight::Repository.find_by(slug: code_value)&.name || code_value
  end

  # Override of ArclightHelper#repository_collections_path
  def repository_collections_path(repository)
    search_action_url(
      f: {
        repository: [repository.slug],
        level: ['Collection']
      }
    )
  end
end

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

  def link_to_repository_location(repository_slug, **link_html_opts)
    repo = Arclight::Repository.find_by(slug: repository_slug)
    return unless repo
    link_url = repo.location.dig(:link, :url)
    link_to(repo.name, link_url, link_html_opts)
  end
end

module RepositoriesHelper
  def repository_label(code_value)
    Arclight::Repository.find_by(slug: code_value)&.name || code_value
  end

  def link_to_repository_location(repository_slug, **link_html_opts)
    repo = Arclight::Repository.find_by(slug: repository_slug)
    return unless repo
    link_url = repo.location.dig(:link, :url)
    link_to(repo.name, link_url, link_html_opts)
  end
end

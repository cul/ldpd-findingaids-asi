# Set the host name for URL creation
host = Rails.application.config.default_host
SitemapGenerator::Sitemap.default_host = host
Rails.application.routes.default_url_options[:host] = host

SitemapGenerator::Sitemap.create do
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host

  search_service = Blacklight.repository_class.new(CatalogController.blacklight_config)
  repositories = Arclight::Repository.all
  repositories.each do |repository|
    count_response = search_service.search(
      q: "level_ssim:Collection repository_id_ssi:\"#{repository.slug}\"",
      rows: 0
      )
    collections_count = count_response['response']['numFound']
    response = search_service.search(
      q: "level_ssim:Collection repository_id_ssi:\"#{repository.slug}\"",
      fl: "id,repository_id_ssi,ead_ssi,aspace_path_ssi,normalized_title_ssm",
      rows: "#{collections_count}"
      )
      collections = response.documents
      collections.each do |collection|
        add repository_finding_aid_path(repository.slug, collection.id), priority: 0.5, changefreq: 'monthly'
      end
    end
end


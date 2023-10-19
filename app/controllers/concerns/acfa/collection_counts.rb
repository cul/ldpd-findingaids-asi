module Acfa::CollectionCounts
  private

  def load_collection_counts
    counts = fetch_collection_counts
    @repositories.each do |repository|
      repository.collection_count = counts[repository.slug] || 0
    end
  end

  def fetch_collection_counts(repository = nil)
    search_service = Blacklight.repository_class.new(blacklight_config)
    q = repository ? "level_ssim:Collection repository_id_ssi:\"#{repository.slug}\"" : 'level_ssim:Collection'
    results = search_service.search(
      q: q,
      'facet.field': 'repository_id_ssi',
      rows: 0
    )
    Hash[*results.facet_fields['repository_id_ssi']]
  end
end

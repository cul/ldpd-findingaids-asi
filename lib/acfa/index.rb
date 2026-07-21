module Acfa::Index
  def self.build_suggester(solr_url)
    # Expunge deletes to clear out any "Deleted Docs" from the index. We have observed that 
    # "Deleted Docs" are read during a suggest dictionary rebuild, and we do not want 
    # to add stale data to the suggester dictionaries.
    # Expunge deletes all "Deleted Docs" only if Solr is configured with a merge policy that sets forceMergeDeletesPctAllowed to 0.0. 
    # If not set, forceMergeDeletesPctAllowed defaults to 10.0, meaning segments with 10% or fewer deleted documents will not be merged, 
    # causing Deleted Docs to not be completely expunged.
    `curl #{solr_url}update?commit=true&expungeDeletes=true`
    # Rebuild all suggester dictionaries
    `curl #{solr_url}suggest?suggest.buildAll=true`
  end
end

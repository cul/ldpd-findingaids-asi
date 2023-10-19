# frozen_string_literal: true

module Acfa
  # This class extends the blacklight search state only
  # to link search results to legacy views of finding aids
  class SearchState < Blacklight::SearchState
    def url_for_document(doc, options = {})

      if doc['aspace_path_ssi'] && (doc_repo = ::Arclight::Repository.find_by(slug: doc['repository_id_ssi']))&.attributes.fetch('aspace_base_uri', nil)
        return doc['aspace_path_ssi'] if doc['aspace_path_ssi'].starts_with?('http')

        File.join(doc_repo.aspace_base_uri, doc['aspace_path_ssi'])
      else # component record, link to dsc
        super
      end
    end
  end
end
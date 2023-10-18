# frozen_string_literal: true

module Acfa
  # This class extends the blacklight search state only
  # to link search results to legacy views of finding aids
  class SearchState < Blacklight::SearchState
    def url_for_document(doc, options = {})

      if controller.is_a?(CatalogController) && controller.action_name == 'show'
        super
      elsif doc['aspace_path_ssi'] && (doc_repo = ::Arclight::Repository.find_by(slug: doc['repository_id_ssi']))&.attributes.fetch('aspace_base_uri', nil)
        return doc['aspace_path_ssi'] if doc['aspace_path_ssi'].starts_with?('http')

        File.join(doc_repo.aspace_base_uri, doc['aspace_path_ssi'])
      elsif doc['component_level_isim'] == [0] # collection record
        { controller: 'finding_aids', action: 'show', repository_id: doc['repository_id_ssi'], id: doc['ead_ssi'] }
      else # component record, link to dsc
        # /ead/nnc-a/ldpd_11077996/dsc#view_all
        finding_aid_id = doc['_root_']
        { controller: 'components', action: 'index', repository_id: doc['repository_id_ssi'], finding_aid_id: finding_aid_id, anchor: 'view_all' }
      end
    end
  end
end
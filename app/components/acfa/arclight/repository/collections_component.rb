# frozen_string_literal: true

module Acfa::Arclight::Repository
  class CollectionsComponent < ViewComponent::Base
    delegate :document_index_view_type, :should_render_field?, to: :helpers
  	attr_accessor :repository

    def initialize(repository:, collections: nil, blacklight_config: nil)
    	@repository = (Arclight::Repository === repository) ? repository : Arclight::Repository.find_by(slug: repository.id)
      @blacklight_config = blacklight_config || CatalogController.blacklight_config
      @collections = collections || fetch_collections
    end

    def collection_link(doc)
      if doc['aspace_path_ssi'] && (doc_repo = ::Arclight::Repository.find_by(slug: doc['repository_id_ssi']))&.attributes.fetch('aspace_base_uri', nil)
        return doc['aspace_path_ssi'] if doc['aspace_path_ssi'].starts_with?('http')

        File.join(doc_repo.aspace_base_uri, doc['aspace_path_ssi'])
      else
        repository_id = doc['repository_id_ssi'] # || @repository.slug
        { controller: '/finding_aids', action: 'show', repository_id: repository_id , id: doc['ead_ssi'] }
      end
    end

    private
    # largely copied from Arclight::RepositoriesController#show
    def fetch_collections
      search_service = Blacklight.repository_class.new(@blacklight_config)
      search_response = search_service.search(
        q: "level_ssim:Collection repository_id_ssi:\"#{@repository.slug}\"",
        fl: "id,repository_id_ssi,ead_ssi,aspace_path_ssi,normalized_title_ssm",
        rows: 100
      )
      search_response.documents
    end
  end
end

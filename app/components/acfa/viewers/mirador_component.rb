# frozen_string_literal: true

module Acfa::Viewers
  # Display the document hierarchy as "breadcrumbs"
  class MiradorComponent < Arclight::EmbedComponent
    attr_accessor :document

    include Acfa::SolrDocument::EmbeddableResources

    def embed_iiif_manifest
      return helpers.solr_document_iiif_collection_url(solr_document_id: @document.id, format: 'json') if embeddable_resources_iiif_manifests[1]
      embeddable_resources_iiif_manifests.first
    end

    def mirador_container(**attrs)
      html_attrs = attrs.dup
      data_attrs = (html_attrs.delete(:data) || {}).merge({ manifest: embed_iiif_manifest, :"use-folders" => use_iiif_folders? })
      if embed_iiif_manifest
        return content_tag(:div, {}, id: 'mirador', data: data_attrs, **html_attrs)
      end
    end

    def use_iiif_folders?
      # TODO: how do we determine when to use the folder UI from the solr data?
      false
    end
  end
end

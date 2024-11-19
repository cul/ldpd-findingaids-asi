class Acfa::IiifCollectionPresenter < Arclight::ShowPresenter
  include Acfa::SolrDocument::EmbeddableResources

  def solr_document_id
    @solr_document_id ||= @view_context.params.require(:solr_document_id)
  end

  def resources
    @document.digital_objects
  end

  def items
    embeddable_resources.map do |r|
      manifest_id = manifest_for(r)
      {
        id: manifest_id,
        type: 'Manifest',
        label: { en: [r.label] }
      } if manifest_id
    end.compact
  end

  def metadata
    fields_to_render.map do |name, field_config, field_presenter|
      {
        label: { en: [field_presenter.label] },
        value: { en: field_presenter.values }
      } if name != 'breadcrumbs'
    end.compact
  end

  def as_json
    collection = {}
    collection["@context"] = ["http://iiif.io/api/auth/2/context.json", "http://iiif.io/api/presentation/3/context.json"]
    collection['id'] = @view_context.solr_document_iiif_collection_url(solr_document_id: solr_document_id, format: :json)
    collection['type'] = 'Collection'
    collection['label'] = heading
    collection['behavior'] = ['multi-part']

    collection['metadata'] = metadata

    collection['items'] = items
    collection.delete('items') if collection['items']&.empty?
    collection.compact
  end
end
require 'rails_helper'

describe CatalogController, type: :routing do
  let(:well_known_id) { 'well-known-id' }
  it 'routes to #iiif_collection' do
    expect(get: "/archives/#{well_known_id}/iiif-collection.json").to route_to(
      action: 'iiif_collection',
      controller: 'catalog',
      solr_document_id: well_known_id,
      format: 'json'
    )
  end
end
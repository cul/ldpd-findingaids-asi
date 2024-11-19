require 'rails_helper'

describe Acfa::IiifCollectionPresenter, type: :unit do
  subject(:presenter) { described_class.new(document, view_context, view_config: view_config) }
  let(:blacklight_config) { CatalogController.blacklight_config }
  let(:digital_objects) { [] }
  let(:document) { instance_double(SolrDocument,
    id: document_id, digital_objects: digital_objects, parents: parents,
    fetch: nil, normalized_title: label) }
  let(:document_id) { 'well-known-id' }
  let(:iiif_id) { "https://example.org/#{document_id}" }
  let(:label) { 'well known label' }
  let(:params) { instance_double(ActionController::Parameters) }
  let(:parents) { [] }
  let(:view_config) { blacklight_config.view_config(:index) }
  let(:view_context) { double }

  before do
    allow(params).to receive(:require).with(:solr_document_id).and_return(document_id)
    allow(view_context).to receive_messages(
      blacklight_config: blacklight_config, solr_document_iiif_collection_url: iiif_id,
      params: params, should_render_field?: false)
  end

  describe '#as_json' do
    it "returns a hash" do
      expect(presenter.as_json).to include('id' => iiif_id, 'label' => label)
    end
  end
end
require 'rails_helper'

describe Acfa::Viewers::MiradorComponent, type: :component do
  subject(:component) { described_class.new(document: document, presenter: document_presenter) }

  let(:digital_objects) { [] }
  let(:document) { instance_double(SolrDocument, id: document_id, digital_objects: digital_objects, parents: parents) }
  let(:document_id) { 'well-known-id' }
  let(:document_presenter) { instance_double(Arclight::ShowPresenter, fields_to_render: [double]) }
  let(:parents) { [] }

  include_context "renderable view components"

  it "does not render" do
    expect(component.render?).to be false
  end

  context "has one embeddable resource" do
    let(:label) { 'resource label' }
    let(:href) { 'https://doi.org/10.7916/d8-3tyk-ew60' }
    let(:iiif_object) { instance_double(Acfa::DigitalObject, label: label, href: href) }
    let(:digital_objects) { [iiif_object] }
    it "renders" do
      expect(rendered_node).to have_selector "div#mirador[data-manifest=\"#{CONFIG[:mirador_base_url]}/iiif/3/presentation/10.7916/d8-3tyk-ew60/manifest\"]"
    end
  end

  context "has multiple embeddable resources" do
    let(:label1) { 'resource label 1' }
    let(:href1) { 'https://doi.org/10.7916/d8-3tyk-ew60' }
    let(:iiif_object1) { instance_double(Acfa::DigitalObject, label: label1, href: href1) }

    let(:label2) { 'resource label 2' }
    let(:href2) { 'https://doi.org/10.7916/d8-3tyk-ew61' }
    let(:iiif_object2) { instance_double(Acfa::DigitalObject, label: label2, href: href2) }

    let(:digital_objects) { [iiif_object1, iiif_object2] }
    it "renders" do
      expect(rendered_node).to have_selector "div#mirador[data-manifest=\"http://test.host/archives/#{document_id}/iiif-collection\"]"
    end
  end
end
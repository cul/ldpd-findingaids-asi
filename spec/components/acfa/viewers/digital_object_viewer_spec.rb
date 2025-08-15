require 'rails_helper'

describe Acfa::Viewers::DigitalObjectViewer, type: :component do
  subject(:component) { described_class.new(document: document, presenter: document_presenter) }

  let(:digital_objects) { [] }
  let(:document) { instance_double(SolrDocument, id: document_id, digital_objects: digital_objects, parents: parents) }
  let(:document_id) { 'well-known-id' }
  let(:document_presenter) { instance_double(Arclight::ShowPresenter, fields_to_render: [double]) }
  let(:parents) { [] }

  include_context "renderable view components"

  it "does not render when no digital objects are present" do
    expect(component.render?).to be false
  end

  context "with a single DOI resource" do
    let(:label) { 'DOI Digital Object' }
    let(:href) { 'https://doi.org/10.7916/d8-3tyk-ew60' }
    let(:role) { nil }
    let(:doi_object) { instance_double(Acfa::DigitalObject, label: label, href: href, role: role) }
    let(:digital_objects) { [doi_object] }

    it "renders DOI resource in Mirador viewer" do
      expect(rendered_node).to have_selector "div#mirador[data-manifest=\"#{CONFIG[:mirador_base_url]}/iiif/3/presentation/10.7916/d8-3tyk-ew60/manifest\"]"
    end
  end

  context "with a single Internet Archive resource" do
    let(:label) { 'Internet Archive Digital Object' }
    let(:href) { 'https://archive.org/details/example-book' }
    let(:role) { nil }
    let(:ia_object) { instance_double(Acfa::DigitalObject, label: label, href: href, role: role) }
    let(:digital_objects) { [ia_object] }

    it "renders Internet Archive resource in Mirador viewer" do
      expect(rendered_node).to have_selector "div#mirador[data-manifest=\"https://iiif.archive.org/iiif/3/example-book/manifest.json\"]"
    end
  end

  context "with an explicit IIIF manifest" do
    let(:label) { 'Dorothy Oak Scrapbook, 1913-1920' }
    let(:href) { 'https://digitalcollections.barnard.edu/do/583250c0-38ec-4c6d-b22e-619185fc2157/metadata/iiifmanifest3cws_scrapbook/default.jsonld' }
    let(:role) { 'iiif-manifest' }
    let(:iiif_object) { instance_double(Acfa::DigitalObject, label: label, href: href, role: role) }
    let(:digital_objects) { [iiif_object] }

    it "renders explicit IIIF manifest in Mirador viewer" do
      expect(rendered_node).to have_selector "div#mirador[data-manifest=\"#{href}\"]"
    end
  end

  context "with a single HathiTrust resource" do
    let(:label) { 'HathiTrust Digital Object' }
    let(:href) { 'https://hdl.handle.net/2027/123456789' }
    let(:role) { nil }
    let(:hathi_object) { instance_double(Acfa::DigitalObject, label: label, href: href, role: role) }
    let(:digital_objects) { [hathi_object] }

    describe '#embed_hathi' do
      it "returns the HathiTrust resource" do
        expect(component.embed_hathi).to eql hathi_object
      end
    end

    it "renders HathiTrust resource in iframe (not Mirador)" do
      expect(rendered_node).to have_selector "iframe[src=\"#{href}?urlappend=%3Bui=embed\"]"
      expect(rendered_node).not_to have_selector "div#mirador"
    end
  end

  context "with multiple DOI embeddable resources" do
    let(:label1) { 'DOI resource 1' }
    let(:href1) { 'https://doi.org/10.7916/d8-3tyk-ew60' }
    let(:doi_object1) { instance_double(Acfa::DigitalObject, label: label1, href: href1, role: nil) }

    let(:label2) { 'DOI resource 2' }
    let(:href2) { 'https://doi.org/10.7916/d8-3tyk-ew61' }
    let(:doi_object2) { instance_double(Acfa::DigitalObject, label: label2, href: href2, role: nil) }

    let(:digital_objects) { [doi_object1, doi_object2] }

    it "renders multiple DOI resources as IIIF collection in Mirador" do
      expect(rendered_node).to have_selector "div#mirador[data-manifest=\"http://test.host/archives/#{document_id}/iiif-collection\"]"
    end

    context "when one DOI resource has explicit IIIF manifest role" do
      let(:href2) { 'https://dlc.library.columbia.edu/iiif/3/presentation/aspace/07a6d30d74e29fabe3cf77fa0e330489/collection' }
      let(:doi_object2) { instance_double(Acfa::DigitalObject, label: label2, href: href2, role: 'iiif-manifest') }

      describe '#embed_iiif_manifest' do
        it "returns only the explicit IIIF manifest" do
          expect(component.embed_iiif_manifest).to eql href2
        end
      end

      it "renders only the explicit IIIF manifest in Mirador" do
        expect(rendered_node).to have_selector "div#mirador[data-manifest=\"#{href2}\"]"
      end
      
      context "when both resources have explicit IIIF manifest roles" do
        let(:href1) { 'https://dlc.library.columbia.edu/iiif/3/presentation/aspace/07a6d30d74e29fabe3cf77fa0e330488/collection' }
        let(:doi_object1) { instance_double(Acfa::DigitalObject, label: label1, href: href1, role: 'iiif-manifest') }

        it "renders multiple explicit IIIF manifests as collection in Mirador" do
          expect(rendered_node).to have_selector "div#mirador[data-manifest=\"http://test.host/archives/#{document_id}/iiif-collection\"]"
        end
      end
    end
  end
end
# frozen_string_literal: true
require 'rexml/document'

require 'rails_helper'

RSpec.describe "catalog/_document.atom.builder", type: :view do
  let(:finding_aid_id) { 'ldpd_ABCDEFG' }
  let(:repository_id) { 'nnc' }
  let(:aspace_base_repository_id) { 'nynybaw' }
  let(:arclight_params) { {_root_: finding_aid_id, repository_id_ssi: repository_id, level_ssim: ['File'], component_level_isim: [3]} }
  let(:collection_params) { arclight_params.merge({id: finding_aid_id, level_ssim: ['Collection'], component_level_isim: [0], ead_ssi: finding_aid_id }) }
  let(:aspace_params) { arclight_params.merge({aspace_path_ssi: '/12345', repository_id_ssi: aspace_base_repository_id}) }
  let(:collection_doc) { SolrDocument.new(id: finding_aid_id, normalized_title_ssm: ['CUL Collection'], **collection_params) }
  let(:local_no_aspace_doc) { SolrDocument.new(id: '123', normalized_title_ssm: ['CUL No ASpace'], level_ssim: [], **arclight_params) }
  let(:local_doc) { SolrDocument.new(id: 'aspace_456', normalized_title_ssm: ['CUL'], **arclight_params) }
  let(:external_aspace_doc) { SolrDocument.new(id: 'aspace_789', normalized_title_ssm: ['BA'], **aspace_params) }

  let(:config) do
    Blacklight::Configuration.new do |config|
      config.index.title_field = 'normalized_title_ssm'
    end
  end

  let(:response_xml) { REXML::Document.new(rendered) }

  let(:html_link) do
    response_xml.elements["/entry/link[@type='text/html']"]
  end

  before do
    allow(view).to receive(:blacklight_config).and_return(config)
    render partial: 'catalog/document', formats: [:atom], handlers: [:builder], locals: {document: solr_document}
  end

  context "a local collection" do
    let(:solr_document) { collection_doc }
    it "includes links and attributes" do
      expect(response_xml.elements["/entry/title"].text).to eq "CUL Collection"
      expect(html_link.attributes['href']).to eq "/archives/#{solr_document[:id]}"
    end
  end

  context "a local resource" do
    let(:solr_document) { local_doc }
    it "includes links and attributes" do
      expect(response_xml.elements["/entry/title"].text).to eq "CUL"
      expect(html_link.attributes['href']).to eq "/archives/#{solr_document[:id]}"
    end
  end

  context "a local resource with non-aspace ID" do
    let(:solr_document) { local_no_aspace_doc }
    it "includes links and attributes" do
      expect(response_xml.elements["/entry/title"].text).to eq "CUL No ASpace"
      expect(html_link.attributes['href']).to eq "/archives/#{solr_document[:id]}"
    end
  end

  context "an external aspace resource" do
    let(:solr_document) { external_aspace_doc }
    it "includes links and attributes" do
      expect(response_xml.elements["/entry/title"].text).to eq "BA"
      expect(html_link.attributes['href']).to eq "/archives/#{solr_document[:id]}"
    end
  end
end
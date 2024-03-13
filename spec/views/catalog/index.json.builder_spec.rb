# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "catalog/index.json", type: :view do
  let(:response) { instance_double(Blacklight::Solr::Response, documents: docs, prev_page: nil, next_page: 2, total_pages: 3) }
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

  let(:docs) do
    [
      collection_doc,
      local_no_aspace_doc,
      local_doc,
      external_aspace_doc
    ]
  end

  let(:config) do
    Blacklight::Configuration.new do |config|
      config.index.title_field = 'normalized_title_ssm'
    end
  end
  let(:presenter) { Blacklight::JsonPresenter.new(response, config) }

  let(:parsed_response) do
    render template: "catalog/index", formats: [:json]
    JSON.parse(rendered).with_indifferent_access
  end

  let(:response_data) { parsed_response[:data] }
  let(:response_links) { parsed_response[:links] }
  let(:response_meta) { parsed_response[:meta] }
  let(:response_pages) { parsed_response.dig(:meta, :pages) }

  before do
    allow(view).to receive(:blacklight_config).and_return(config)
    allow(view).to receive(:search_action_path).and_return('http://test.host/some/search/url')
    allow(view).to receive(:search_facet_path).and_return('http://test.host/some/facet/url')
    allow(presenter).to receive(:pagination_info).and_return(current_page: 1,
                                                             next_page: 2,
                                                             prev_page: nil)
    allow(presenter).to receive(:search_facets).and_return([])
    assign :presenter, presenter
    assign :response, response
  end

  it "has pagination links" do
    expect(response_links).to include({
      self: 'http://test.host/archives.json',
      next: 'http://test.host/archives.json?page=2',
      last: 'http://test.host/archives.json?page=3'
    })
  end

  it "has pagination information" do
    expect(response_pages).to include(
      {
        'current_page' => 1,
        'next_page' => 2,
        'prev_page' => nil
      })
  end

  context "includes documents, links, and their attributes" do
    it "serializes a local collection" do
      expect(response_data).to include(
        {
          id: 'ldpd_ABCDEFG',
          type: 'Collection',
          attributes: {
            title: 'CUL Collection'
          },
          links: { self: '/archives/ldpd_ABCDEFG' }
        }
      )
    end

    it "serializes a local resource with non-aspace ID" do
      expect(response_data).to include(
        {
          id: '123',
          type: 'File',
          attributes: {
            title: 'CUL No ASpace'
          },
          links: { self: '/archives/123' }
        }
      )
    end

    it "serializes a local resource with aspace ID" do
      expect(response_data).to include(
        {
          id: 'aspace_456',
          type: 'File',
          attributes: {
            title: 'CUL'
          },
          links: { self: '/archives/aspace_456' }
        }
      )
    end

    it "serializes an external aspace resource" do
      expect(response_data).to include(
        {
          id: 'aspace_789',
          type: 'File',
          attributes: {
            title: 'BA'
          },
          links: { self: '/archives/aspace_789' }
        }
      )
    end
  end
end
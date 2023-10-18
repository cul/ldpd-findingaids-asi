require 'rails_helper'
require 'acfa/search_state.rb'

RSpec.describe Acfa::SearchState do
  subject(:search_state) { described_class.new(params, blacklight_config) }
  let(:params) { ActionController::Parameters.new }
  let(:blacklight_config) { Blacklight::Configuration.new }
  let(:repository_id) { 'nnc' }
  let(:document_id) { '1234567' }
  let(:finding_aid_id) { 'x123.56' }
  let(:aspace_path) { '/7654321' }
  let(:document) { SolrDocument.new({repository_id_ssi: repository_id, id: document_id, aspace_path_ssi: aspace_path, _root_: finding_aid_id}) }
  let(:actual) { search_state.url_for_document(document) }
  context "repo has no aspace_base_uri configured" do
    let(:expected) { { repository_id: repository_id, finding_aid_id: finding_aid_id, controller: 'components', action: 'index', anchor: 'view_all' } }
    it 'fails' do
      expect(actual).to eql(expected)
    end
  end
  context "repo has aspace_base_uri configured" do
    let(:expected) { 'http://localhost/7654321' }
    before do
      ENV['REPOSITORY_FILE'] = File.join(file_fixture_path, 'config/aspace_repositories.yml')
    end
    after do
      ENV['REPOSITORY_FILE'] = nil
    end
    it 'fails' do
      expect(actual).to eql(expected)
    end
  end
end

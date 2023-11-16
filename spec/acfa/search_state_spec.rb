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
  let(:doc_attrs) { { repository_id_ssi: repository_id, id: document_id, aspace_path_ssi: aspace_path, _root_: finding_aid_id } }
  let(:document) { SolrDocument.new(doc_attrs) }
  let(:actual) { search_state.url_for_document(document) }
  context "repo has no aspace_base_uri configured" do
    let(:expected) { { repository_id: repository_id, finding_aid_id: finding_aid_id, controller: 'components', action: 'index', anchor: 'view_all' } }
    it 'returns expected routing params' do
      expect(actual).to eql(expected)
    end
    context 'document is an aspace resource' do
      let(:aspace_id) { 'aspace1234567' }
      let(:id) { "#{finding_aid_id}#{aspace_id}" }
      let(:parent_titles) { ['Test Collection', 'Series IX: Test Series', "Box 24"] }
      let(:titles) { ['Digital Object'] }
      let(:aspace_attrs) { { id: id, parent_unittitles_ssm: parent_titles, title_ssm: titles } }
      let(:document) { SolrDocument.new(doc_attrs.merge(aspace_attrs)) }
      let(:expected) { { repository_id: repository_id, finding_aid_id: finding_aid_id, controller: 'components', action: 'show', anchor: aspace_id, id: 9 } }

      it 'returns expected routing params' do
        expect(actual).to eql(expected)
      end

      context 'aspace resource is a series' do
        let(:parent_titles) { ['Test Collection'] }
        let(:titles) { ['Series IX: Test Series'] }
        let(:expected) { { repository_id: repository_id, finding_aid_id: finding_aid_id, controller: 'components', action: 'show', id: 9 } }

        it 'returns expected routing params' do
          expect(actual).to eql(expected)
        end
      end

      context 'series is unclear' do
        let(:parent_titles) { ['Test Collection', 'Series Alpha: Test Series', "Box 24"] }
        let(:titles) { ['Digital Object'] }
        let(:expected) { { repository_id: repository_id, finding_aid_id: finding_aid_id, controller: 'components', action: 'index', anchor: aspace_id } }

        it 'returns expected routing params' do
          expect(actual).to eql(expected)
        end
      end
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
    it 'returns a composed link literal' do
      expect(actual).to eql(expected)
    end
  end

  describe '.roman_to_arabic' do
    it "works" do
      expect(described_class.roman_to_arabic('I')).to be 1
      expect(described_class.roman_to_arabic('II')).to be 2
      expect(described_class.roman_to_arabic('IV')).to be 4
      expect(described_class.roman_to_arabic('V')).to be 5
      expect(described_class.roman_to_arabic('XIV')).to be 14
      expect(described_class.roman_to_arabic('XIX')).to be 19
      expect(described_class.roman_to_arabic('XXVII')).to be 27
      expect(described_class.roman_to_arabic('LXVI')).to be 66
      expect(described_class.roman_to_arabic('CLXVI')).to be 166
      expect(described_class.roman_to_arabic('DCCLXXXIX')).to be 789
      expect(described_class.roman_to_arabic('mdcclxxvi')).to be 1776
    end
  end
end

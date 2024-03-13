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
    it 'fails' do
      expect(actual).to be(document)
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

# frozen_string_literal: true

require 'rails_helper'
require 'arclight/traject/nokogiri_namespaceless_reader'

describe Traject::Indexer do
  subject(:indexer) do
    _indexer = Traject::Indexer::NokogiriIndexer.new
    _indexer.load_config_file(Rails.root.join('lib/ead/traject/ead2_config.rb'))
    _indexer
  end
  let(:fixture_file) do
    File.read(fixture_path)
  end
  let(:nokogiri_reader) do
    Arclight::Traject::NokogiriNamespacelessReader.new(File.read(fixture_path), {})
  end
  let(:records) do
    nokogiri_reader.to_a
  end
  let(:record) do
    records.first
  end
  let(:index_document) { subject.map_record(record).with_indifferent_access }
  describe 'eadid' do
    let(:expected_value) { 'ldpd_1234567' }
    context 'is given in /ead/archdesc/unitid[1]/text()' do
      let(:fixture_path) { File.join(file_fixture_path, 'ead/test_eadid/from_unitid.xml') }
      it { expect(index_document).not_to be_nil }
      it { expect(index_document[:id]).to eql [expected_value] }
      it { expect(index_document[:ead_ssi]).to eql [expected_value] }
    end

    context 'is given in /ead/eadheader/eadid[1]/text()' do
      let(:fixture_path) { File.join(file_fixture_path, 'ead/test_eadid/from_eadid_text.xml') }
      it { expect(index_document).not_to be_nil }
      it { expect(index_document[:id]).to eql [expected_value] }
      it { expect(index_document[:ead_ssi]).to eql [expected_value] }
    end

    context 'is given in /ead/archdesc/eadid[1]/@url' do
      let(:fixture_path) { File.join(file_fixture_path, 'ead/test_eadid/from_eadid_att.xml') }
      it { expect(index_document).not_to be_nil }
      it { expect(index_document[:id]).to eql [expected_value] }
      it { expect(index_document[:ead_ssi]).to eql [expected_value] }
    end
  end
  describe 'date_range_* indexing' do
    context 'has bulk range' do
      let(:expected) { (1958..1980).to_a }
      let(:fixture_path) { File.join(file_fixture_path, 'ead/test_unitdate/has_bulk_range.xml') }
      it { expect(index_document).not_to be_nil }
      it { expect(index_document[:date_range_isim]).to eql(expected) }
    end
    context 'has open-end encoded as 9999' do
      let(:fixture_path) { File.join(file_fixture_path, 'ead/test_unitdate/open_ended_9999.xml') }
      it { expect(index_document).not_to be_nil }
      it { expect(index_document[:date_range_isim]).to be_blank }
      it { expect(index_document[:date_range_ssim]).to be_blank }
    end
    context 'has very large range' do
      let(:fixture_path) { File.join(file_fixture_path, 'ead/test_unitdate/too_large_date_range.xml') }
      it { expect(index_document).not_to be_nil }
      it { expect(index_document[:date_range_isim]).to be_blank }
      it { expect(index_document[:date_range_ssim]).to be_blank }
    end
  end
  describe 'repository indexing' do
    let(:repository_id) { 'nnc-a' }
    let(:repository_name) { REPOS[repository_id][:name] }
    let(:fixture_path) { File.join(file_fixture_path, 'ead/test_ead.xml') }
    # the accumulator will wrap in an array
    it { expect(index_document[:repository_id_ssi]).to eql [repository_id] }
    it { expect(index_document[:repository_ssim]).to eql [repository_name] }
    context 'has a UA call number' do
      let(:repository_id) { 'nnc-ua' }
      let(:repository_name) { REPOS[repository_id][:name] }
      let(:fixture_path) { File.join(file_fixture_path, 'ead/test_repo_id_exception.xml') }
      # the accumulator will wrap in an array
      it { expect(index_document[:repository_id_ssi]).to eql [repository_id] }
      it { expect(index_document[:repository_ssim]).to eql [repository_name] }
    end
  end
  describe 'aspace path indexing' do
      let(:fixture_path) { File.join(file_fixture_path, 'ead/test_eadid/from_unitid.xml') }
      let(:expected_value) { '/7654321' }
      it { expect(index_document).not_to be_nil }
      it { expect(index_document[:aspace_path_ssi]).to eql [expected_value] }
  end
  describe 'language indexing' do
      let(:fixture_path) { File.join(file_fixture_path, 'ead/test_ead.xml') }
      let(:expected_language_value) { 'Dutch' }
      let(:expected_language_material_value) { 'Material is in English and in French, with some materials in Dutch.' }
      it { expect(index_document).not_to be_nil }
      it { expect(index_document[:language_ssim]).to eql [expected_language_value] }
      it { expect(index_document[:language_material_ssm]).to include expected_language_material_value }
  end
  describe 'aspace path indexing' do
      let(:fixture_path) { File.join(file_fixture_path, 'ead/test_eadid/from_unitid.xml') }
      let(:expected_value) { 'Ead Fixture' }
      it { expect(index_document).not_to be_nil }
      it { expect(index_document[:collection_sort]).to eql [expected_value] }
  end
end
# frozen_string_literal: true

require 'rails_helper'
require 'arclight/traject/nokogiri_namespaceless_reader'

describe Traject::Indexer do
  subject(:indexer) do
    _indexer = Traject::Indexer::NokogiriIndexer.new
    _indexer.load_config_file(Rails.root.join('lib/ead/traject/ead2_config.rb'))
    _indexer
  end
  let(:fixture_file_data) do
    File.read(fixture_path)
  end
  let(:nokogiri_reader) do
    Arclight::Traject::NokogiriNamespacelessReader.new(fixture_file_data, {})
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
  describe 'call number indexing' do
      let(:fixture_path) { File.join(file_fixture_path, 'ead/test_ead.xml') }
      let(:expected_value) { 'MS#0030' }
      it do
        expect(index_document).not_to be_nil
        expect(index_document[:components][0][:call_number_ss]).to eql [expected_value]
        expect(index_document[:components][0][:components][0][:call_number_ss]).to eql [expected_value]
        expect(index_document[:components][0][:components][0][:components][0][:call_number_ss]).to eql [expected_value]
      end
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
  describe 'container information indexing' do
    let(:fixture_path) { File.join(file_fixture_path, 'ead/test_ead.xml') }
    let(:info_for_one_of_the_containers) do
      index_document[:components][0][:components][2][:container_information_ssm].map {|info_json| JSON.parse(info_json) }
    end
    it do
      expect(index_document).not_to be_nil
    end
    it 'extracts the expected information for a known box' do
      expect(info_for_one_of_the_containers).to include(
        {
          'barcode' => 'RH00002380',
          'id' => 'ef18c12f57c6c1c39c2f2ece677e6070',
          'parent' => '',
          'label' => 'box 230',
          'type' => 'box',
        }
      )
    end
    it 'extracts the expected information for a known folder' do
      expect(info_for_one_of_the_containers).to include(
        {
          'barcode' => nil,
          'id' => 'b4ed1e77add4128f44588571fcd85b7e',
          'parent' => 'ef18c12f57c6c1c39c2f2ece677e6070',
          'label' => 'folder 1 to 3',
          'type' => 'folder'
        }
      )
    end
  end

  describe 'unprocessed access note indexing' do
    let(:fixture_path) { File.join(file_fixture_path, 'ead/test_ead.xml') }
    let(:fixture_file_data) do
      File.read(fixture_path).gsub('This collection is PLACEHOLDER_PROCESSING_STATUS.', "This collection is #{keyword}.")
    end
    context 'when unprocessed/vetted keywords are not present' do
      let(:keyword) { 'fine' }
      it do
        expect(index_document[:components][0][:aeon_unprocessed_ssi]).to eq([false])
      end
    end
    context 'when "unprocessed" keyword is present' do
      let(:keyword) { 'unprocessed' }
      it do
        expect(index_document[:components][0][:aeon_unprocessed_ssi]).to eq([true])
      end
    end
    context 'when "vetted" keyword is present' do
      let(:keyword) { 'vetted' }
      it do
        expect(index_document[:components][0][:aeon_unprocessed_ssi]).to eq([true])
      end
    end
    context 'when a mixed-case relevant keyword is present' do
      let(:keyword) { 'VeTtEd' }
      it do
        expect(index_document[:components][0][:aeon_unprocessed_ssi]).to eq([true])
      end
    end
  end

  describe 'offsite collection access note indexing' do
    let(:fixture_path) { File.join(file_fixture_path, 'ead/test_ead.xml') }
    let(:fixture_file_data) do
      File.read(fixture_path).gsub('This collection is PLACEHOLDER_O.F.F.S.I.T.E_STATUS.', "This collection is #{keyword}.")
    end
    context 'when the offsite keyword is not present' do
      let(:keyword) { 'onsite' }
      it do
        expect(index_document[:components][0][:collection_offsite_ssi]).to eq([false])
      end
    end
    context 'when the "offsite" keyword is present' do
      let(:keyword) { 'offsite' }
      it do
        expect(index_document[:components][0][:collection_offsite_ssi]).to eq([true])
      end
    end
    context 'when the "off-site" keyword is present' do
      let(:keyword) { 'off-site' }
      it do
        expect(index_document[:components][0][:collection_offsite_ssi]).to eq([true])
      end
    end
    context 'when the "off site" keyword is present' do
      let(:keyword) { 'off site' }
      it do
        expect(index_document[:components][0][:collection_offsite_ssi]).to eq([true])
      end
    end
  end

  describe 'restricted/closed/missing access note indexing' do
    let(:fixture_path) { File.join(file_fixture_path, 'ead/test_ead.xml') }
    let(:fixture_file_data) do
      File.read(fixture_path).gsub('[Vetted, PLACEHOLDER_AVAILABILITY_KEYWORD]', "[Vetted, #{keyword}]")
    end
    context 'when restricted/closed/missing keywords are not present' do
      let(:keyword) { 'open' }
      it do
        expect(index_document[:components][0][:components][0][:components][0][:aeon_unavailable_for_request_ssi]).to eq([false])
      end
    end
    context 'when "restricted" keyword is present' do
      let(:keyword) { 'restricted' }
      it do
        expect(index_document[:components][0][:components][0][:components][0][:aeon_unavailable_for_request_ssi]).to eq([true])
      end
    end
    context 'when "closed" keyword is present' do
      let(:keyword) { 'closed' }
      it do
        expect(index_document[:components][0][:components][0][:components][0][:aeon_unavailable_for_request_ssi]).to eq([true])
      end
    end
    context 'when "missing" keyword is present' do
      let(:keyword) { 'missing' }
      it do
        expect(index_document[:components][0][:components][0][:components][0][:aeon_unavailable_for_request_ssi]).to eq([true])
      end
    end
    context 'when a mixed-case relevant keyword is present' do
      let(:keyword) { 'MiSsInG' }
      it do
        expect(index_document[:components][0][:components][0][:components][0][:aeon_unavailable_for_request_ssi]).to eq([true])
      end
    end
  end
end

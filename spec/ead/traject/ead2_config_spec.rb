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
    context 'has open-end encoded as 9999' do
      let(:fixture_path) { File.join(file_fixture_path, 'ead/test_unitdate/open_ended_9999.xml') }
      it { expect(index_document).not_to be_nil }
      it { expect(index_document[:date_range_isim]).to be_blank }
      it { expect(index_document[:date_range_ssim]).to be_blank }
    end
  end
end
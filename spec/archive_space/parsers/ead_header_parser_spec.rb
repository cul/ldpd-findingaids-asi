require 'rails_helper'
require 'archive_space/parsers/ead_header_parser.rb'

attributes = [
  :eadid_url_attribute, # <eadid url= >
  :publication_statement_publisher, # <filedesc><publicationstmt><publisher>
  :revision_description_changes # <revisiondesc><change>
].freeze

RSpec.describe ArchiveSpace::Parsers::EadHeaderParser do
  ########################################## API/interface
  describe 'API/interface' do
    context 'has attr_reader for instance var' do
      attributes.each do |attribute|
        it "#{attribute}" do
          expect(subject).to respond_to("#{attribute}")
        end
      end
    end

    context 'has ' do
      it 'has #parse method' do
        expect(subject).to respond_to(:parse).with(1).arguments
      end
    end
  end

  ########################################## Functionality
  describe '-- Validate functionality -- ' do
    before(:context) do
      xml_input = fixture_file_upload('ead/test_ead.xml').read
      nokogiri_xml_document = Nokogiri::XML(xml_input) do |config|
            config.norecover
          end
      @ead_header_parser = ArchiveSpace::Parsers::EadHeaderParser.new
      @ead_header_parser.parse nokogiri_xml_document
    end

    ########################################## parse
    describe 'method #parse' do
      it 'sets the eadid_url_attribute attribute correctly' do
        retrieved_value = @ead_header_parser.eadid_url_attribute
        expect(retrieved_value).to eq 'http://findingaids.cul.columbia.edu/ead/nnc-a/ldpd_11266912/summary'
      end

      it 'sets the publication_statement_publisher attribute correctly' do
        retrieved_value = @ead_header_parser.publication_statement_publisher
        expect(retrieved_value).to eq 'Avery Architectural and Fine Arts Library'
      end

      it 'sets the revision_description_changes attribute correctly' do
        retrieved_values = @ead_header_parser.revision_description_changes
        expect(retrieved_values[0].date).to eq '2015-02-28'
        expect(retrieved_values[0].item).to eq 'File created.'
        expect(retrieved_values[1].date).to eq '2019-05-20'
        expect(retrieved_values[1].item).to eq 'EAD was imported spring 2019 as part of the ArchivesSpace Phase II migration.'        
      end
    end
  end
end

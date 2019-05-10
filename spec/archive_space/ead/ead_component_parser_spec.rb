require 'rails_helper'
require 'archive_space/ead/ead_parser.rb'
require 'archive_space/ead/ead_component_parser.rb'

attributes = [
  :title, # <c>:<did>:<unititle>
  :scope_content_value # <c>:<scopecontent>:<p>
].freeze

RSpec.describe ArchiveSpace::Ead::EadComponentParser do
  ########################################## API/interface
  describe 'API/interface' do
    context 'has attr_reader for instance var' do
      attributes.each do |attribute|
        it "#{attribute}" do
          expect(subject).to respond_to("#{attribute}")
        end
      end
    end

    context 'has' do
      it 'parse method that takes one argument' do
        expect(subject).to respond_to(:parse).with(1).argument
      end

      it 'generate_info method that takes no arguments' do
        expect(subject).to respond_to(:generate_info).with(0).arguments
      end

      it 'generate_child_components_info that takes one argument' do
        expect(subject).to respond_to(:generate_child_components_info).with(2).arguments
      end

      it 'generate_component_info that takes one argument' do
        expect(subject).to respond_to(:generate_component_info).with(1).arguments
      end
    end
  end

  ########################################## Functionality
  describe 'Testing functionality: ' do
    ########################################## generate_info
    context 'generate_info' do
      before(:example) do
        xml_input = fixture_file_upload('asi/test_c_element.xml').read
        @nokogiri_xml = Nokogiri::XML(xml_input)
        @as_ead_series = ArchiveSpace::Ead::EadComponentParser.new
        @as_ead_series.parse @nokogiri_xml.xpath('/xmlns:ead/xmlns:archdesc/xmlns:dsc/xmlns:c[@level="series"]')
      end

      let (:expected) {
        [
          [0,
           "Series I: Cataloged Correspondence",
           "",
           "series",
           "In four boxes, numbered 1-4. Kent's letters are arranged chronologically in Boxes 2: (1918-1940); 3: (1941-1969).",
           "*In addition, a sortable inventory in this downloadable Excel spreadsheet.",
           []
          ]
        ]
      }

      it 'generate the correct info' do
        tested = @as_ead_series.generate_info
        expect(tested).to eq expected
      end
    end

    ########################################## parse
    context 'parse' do
      before(:example) do
        xml_input = fixture_file_upload('asi/test_c_element.xml').read
        @nokogiri_xml = Nokogiri::XML(xml_input)
        @as_ead_series = ArchiveSpace::Ead::EadComponentParser.new
        @as_ead_series.parse @nokogiri_xml.xpath('/xmlns:ead/xmlns:archdesc/xmlns:dsc/xmlns:c[@level="series"]')
      end

      it 'sets the title correctly' do
        tested = @as_ead_series.title
        expect(tested).to eq 'Series I: Cataloged Correspondence'
      end

      it 'sets the scope content correctly' do
        tested = @as_ead_series.scope_content_value
        expect(tested).to include "Kent's letters are arranged chronologically in Boxes 2: (1918-1940); 3: (1941-1969)"
      end
    end
  end
end

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
        @nesting_level, @title, @date, @level, @scope_content_values, @other_finding_aid, @container_info = @as_ead_series.generate_info.first
      end

      let (:expected_scope_content_values) {
        [
          "In four boxes, numbered 1-4.",
          "The Builder. Nov 11, 1921. Excerpt;",
          "Notice de la constitution des societe local."
        ]
      }

      it 'generates the correct nesting level' do
        expect(@nesting_level).to eq 0
      end

      it 'generates the correct title' do
        expect(@title).to eq 'Series I: Cataloged Correspondence'
      end

      it 'generates the correct level' do
        expect(@level).to eq 'series'
      end

      it 'generates the correct scope content values' do
        @scope_content_values.each_with_index do |scope_content_value, index|
          expect(scope_content_value.text).to eq expected_scope_content_values[index]
        end
      end

      it 'generates the correct other finding aid' do
        expect(@other_finding_aid).to eq '*In addition, a sortable inventory in this downloadable Excel spreadsheet.'
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
        expect(tested).to include "In four boxes, numbered 1-4."
      end
    end
  end
end

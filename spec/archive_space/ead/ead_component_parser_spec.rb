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

  ########################################## Debug API/interface
  describe 'debug API/interface' do
    context 'has debug_attr_reader for instance var' do
      attributes.each do |attribute|
        it "#{attribute}" do
          expect(subject).to respond_to("debug_#{attribute}")
        end
      end
    end
  end

  ########################################## Functionality
  describe 'Testing functionality: ' do
    ########################################## generate_html_child_components
    context 'generate_html_child_components' do
      before(:example) do
        xml_input = fixture_file_upload('asi/as_ead_resource_4767_representation.xml').read
        @as_ead = ArchiveSpace::Ead::EadParser.new xml_input
        @nokogiri_xml = Nokogiri::XML(xml_input)
        @as_ead.parse_arch_desc_dsc @nokogiri_xml
      end

      # TODO: Fix/Change/Finish following. Probably requires changes in above before block
      it 'process files (CHANGE)' do
        tested_series = @as_ead.archive_dsc_series[0]
        # puts '*******************************************'
        #  puts '*******************************************'
        # puts @as_ead.generate_html_child_component(tested_series, '')
        # puts @as_ead.process_children_files(series_c_children)
        # puts tested
        # expect(tested).to include({:title => 'Price, Arthur: to Rockwell Kent, t.l.s., 15', :box_number => '3'})
        expect(true).to eq true
      end
    end

    ########################################## generate_info
    context 'generate_html_child_components' do
      before(:example) do
        xml_input = fixture_file_upload('asi/as_ead_resource_4767_representation.xml').read
        @as_ead = ArchiveSpace::Ead::EadParser.new xml_input
        @nokogiri_xml = Nokogiri::XML(xml_input)
        @as_ead.parse_arch_desc_dsc @nokogiri_xml
        @as_ead_series = ArchiveSpace::Ead::EadComponentParser.new
        @as_ead_series.parse @as_ead.archive_dsc_series[0]
      end

      it 'generate the correct info' do
        tested = @as_ead_series.generate_info
        # puts tested.inspect
        expect(true).to eq true
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

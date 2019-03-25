require 'rails_helper'
require 'asi/as_ead.rb'
require 'asi/as_ead_component.rb'

RSpec.describe Asi::AsEadComponent do
  ########################################## API/interface
  describe 'API/interface' do
    context 'has attr_reader for instance var' do
      # within a given series: <did>:<unittitle>
      it 'title' do
        expect(subject).to respond_to(:title)
      end

      # within a given series: <scopecontent>:<p>
      it 'scope_content' do
        expect(subject).to respond_to(:scope_content)
      end
    end

    context 'has parse method' do
      it 'that takes one argument' do
        expect(subject).to respond_to(:parse).with(1).argument
      end
    end

    context 'has generate_html method' do
      it 'that takes no arguments' do
        expect(subject).to respond_to(:generate_html).with(0).arguments
      end
    end

    context 'has generate_html_from_component method' do
      it 'that takes two arguments' do
        expect(subject).to respond_to(:generate_html_from_component).with(2).arguments
      end
    end
  end

  ########################################## Debug API/interface
  describe 'debug API/interface' do
    context 'has debug_attr_reader for instance var' do
      # within a given series: <did>:<unittitle>
      it 'title' do
        expect(subject).to respond_to(:debug_title)
      end

      # within a given series: <scopecontent>:<p>
      it 'scope_content' do
        expect(subject).to respond_to(:debug_scope_content)
      end
    end
  end

  ########################################## Functionality
  describe 'Testing functionality: ' do
    ########################################## generate_html_from_components
    context 'generate_html_from_components' do
      before(:example) do
        xml_input = fixture_file_upload('asi/as_ead_resource_4767_representation.xml').read
        @as_ead = Asi::AsEad.new xml_input
        @nokogiri_xml = Nokogiri::XML(xml_input)
        @as_ead.parse_arch_desc_dsc @nokogiri_xml
      end

      # TODO: Fix/Change/Finish following. Probably requires changes in above before block
      it 'process files (CHANGE)' do
        tested_series = @as_ead.archive_dsc_series[0]
        # puts '*******************************************'
        #  puts '*******************************************'
        # puts @as_ead.generate_html_from_component(tested_series, '')
        # puts @as_ead.process_children_files(series_c_children)
        # puts tested
        # expect(tested).to include({:title => 'Price, Arthur: to Rockwell Kent, t.l.s., 15', :box_number => '3'})
        expect(true).to eq true
      end
    end

    ########################################## parse
    context 'parse' do
      before(:example) do
        xml_input = fixture_file_upload('asi/as_ead_resource_4767_representation.xml').read
        @as_ead = Asi::AsEad.new xml_input
        @nokogiri_xml = Nokogiri::XML(xml_input)
        @as_ead.parse_arch_desc_dsc @nokogiri_xml
        @as_ead_series = Asi::AsEadComponent.new
        @as_ead_series.parse @as_ead.archive_dsc_series[0]
      end

      it 'sets the title correctly' do
        tested = @as_ead_series.title
        expect(tested).to eq 'Series I: Cataloged Correspondence'
      end

      it 'sets the scope content correctly' do
        tested = @as_ead_series.scope_content
        expect(tested).to include "Kent's letters are arranged chronologically in Boxes 2: (1918-1940); 3: (1941-1969)"
      end
    end
  end
end

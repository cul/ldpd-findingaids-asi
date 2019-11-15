require 'rails_helper'
require 'ead/elements/dsc.rb'

class_methods = [
  :c_level_attribute_series_array, # <c> Component (Unnumbered), <c level="series">
].freeze


RSpec.describe Ead::Elements::Dsc do
  ########################################## API/interface
  describe '-- Validate API/interface --' do
    context 'has class method' do
      class_methods.each do |class_method|
        it "#{class_method}" do
          expect(subject.class).to respond_to("#{class_method}")
        end
      end
    end
  end

  ########################################## Functionality
  describe '-- Validate functionality --' do
    before(:context) do
      input_xml = fixture_file_upload('ead/test_ead.xml').read
      nokogiri_document = Nokogiri::XML(input_xml)
      @nokogiri_node_set = Nokogiri::XML(input_xml).xpath('/xmlns:ead/xmlns:archdesc/xmlns:dsc')
      # puts @nokogiri_node_set.inspect
    end

    describe ' class methods that return an array:' do
      context 'class method' do
        let (:expected_series_unittitles) {
          [
            'Series I: Cataloged Correspondence',
            'Series II: Cataloged Drawings'
          ]
        }
        
        it 'c_level_attribute_series_array takes a <dsc> and returns an array of <c level="series">}>' do
          series = Ead::Elements::Dsc.c_level_attribute_series_array(@nokogiri_node_set)
          expected_series_unittitles.each_with_index do |expected_series_unittitle, index|
            expect(series[index].xpath('./xmlns:did/xmlns:unittitle').text).to eq expected_series_unittitle
          end
        end
      end
    end
  end
end

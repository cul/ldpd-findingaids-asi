require 'rails_helper'
require 'archive_space/parsers/archival_description_dsc_parser.rb'

all_attributes = [
  :series_compound_title_array,
  :subseries_compound_title_array_for_each_series_array
#  :series_date_string_array, # <ead>:<archdesc>:<c level="series">:<did>:<unitdate>
#  :series_title_array, # <ead>:<archdesc>:<c level="series">:<did>:<unittile>
].freeze

# following is a subset of the above array
attributes_tested_individually = [
  :subseries_compound_title_array_for_each_series_array
].freeze

single_value_attributes = [
].freeze

RSpec.describe ArchiveSpace::Parsers::ArchivalDescriptionDscParser do
  ########################################## API/interface
  describe 'API/interface' do
    context 'has attr_reader for instance var' do
      all_attributes.each do |attribute|
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
      @arch_desc_dsc_parser = ArchiveSpace::Parsers::ArchivalDescriptionDscParser.new
      @arch_desc_dsc_parser.parse xml_input
    end

    ########################################## parse
    describe 'method #parse' do
      let (:expected_series_compound_title_array) {
        [
          'Series I: Cataloged Correspondence, 1914-1989, 1894-1967, bulk 1958-1980',
          'Series II: Cataloged Drawings, 1914-1989, 1897-1967, bulk 1958-1980'
        ]
      }

      let (:expected_subseries_compound_title_array_for_each_series_array) {
        [
          [
            'Subseries 1: Cataloged Correspondence -- Letters, 1914-1915, 1894-1960, bulk 1958-1960',
            'Subseries 2: Cataloged Correspondence - Postcards, 1914-1916, 1894-1961, bulk 1958-1961'
          ],
          [
            'Subseries 1: Cataloged Drawings -- Sketches, 1914-1920, 1894-1970, bulk 1958-1970',
            'Subseries 2: Cataloged Drawings -- Blueprints, 1914-1940, 1894-1980, bulk 1958-1980'
          ]
        ]
      }

      context 'given 2 series with 2 subseries each' do
        it "sets the subseries_compound_title_array_for_each_series_array attribute correctly" do
          values = @arch_desc_dsc_parser.subseries_compound_title_array_for_each_series_array
          expect(values.size).to eq expected_subseries_compound_title_array_for_each_series_array.size
          expected_subseries_compound_title_array_for_each_series_array.each_with_index do |subseries_compound_title_array, i|
            expect(values[i].size).to eq subseries_compound_title_array.size
            subseries_compound_title_array.each_with_index do |subseries_compound_title, j|
              expect(values[i,j]).to eq expected_subseries_compound_title_array_for_each_series_array[i,j]
            end
          end
        end
      end

      context 'sets correctly attributes that return an array:' do
        (all_attributes - attributes_tested_individually).each do |attribute|
          it "sets the #{attribute} attribute correctly" do
            expected_values = eval "expected_#{attribute}"
            expected_values.each_with_index do |expected_value, index|
              expect(@arch_desc_dsc_parser.instance_variable_get("@#{attribute}")[index]).to eq expected_value
            end
          end
        end
      end

      context 'sets correctly attributes that return an single value:' do
        single_value_attributes.each do |attribute|
          it "sets the #{attribute} attribute correctly" do
            expected_value = eval "expected_#{attribute}"
            expect(@arch_desc_dsc_parser.instance_variable_get("@#{attribute}")).to eq expected_value
          end
        end
      end
    end
  end
end

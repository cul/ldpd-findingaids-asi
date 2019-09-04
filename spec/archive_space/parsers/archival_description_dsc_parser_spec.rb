require 'rails_helper'
require 'archive_space/parsers/archival_description_dsc_parser.rb'

all_attributes = [
  :series_compound_title_array,
#  :series_date_string_array, # <ead>:<archdesc>:<c level="series">:<did>:<unitdate>
#  :series_title_array, # <ead>:<archdesc>:<c level="series">:<did>:<unittile>
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
          'Series II: Cataloged Pictures, 1914-1989, 1897-1967, bulk 1958-1980'
        ]
      }

      context 'sets correctly attributes that return an array:' do
        (all_attributes - single_value_attributes).each do |attribute|
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

require 'rails_helper'
require 'archive_space/parsers/archival_description_dsc_parser.rb'

all_attributes = [
  :scope_content_values_for_each_series,
  :series_compound_title_array,
  # Following attribute is a hash, with each key being a series compound title, and the value
  # for that key is an array of the subseries compound titles for the subseries
  # contained within that series
  :series_subseries_compound_titles_hash,
  # Following attribute is an array of arrays: each internal array contains the
  # subseries compound titles (unittitle and unitdates) for the given parent series
  :subseries_compound_title_array_for_each_series_array
#  :series_date_string_array, # <ead>:<archdesc>:<c level="series">:<did>:<unitdate>
#  :series_title_array, # <ead>:<archdesc>:<c level="series">:<did>:<unittile>
].freeze

# following is a subset of the above array
attributes_tested_individually = [
  :scope_content_values_for_each_series,
  :series_subseries_compound_titles_hash,
  :subseries_compound_title_array_for_each_series_array
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
      nokogiri_xml_document = Nokogiri::XML(xml_input) do |config|
        config.norecover
      end
      @arch_desc_dsc_parser = ArchiveSpace::Parsers::ArchivalDescriptionDscParser.new
      @arch_desc_dsc_parser.parse nokogiri_xml_document
    end

    ########################################## parse
    describe 'method #parse' do
      let (:expected_scope_content_values_for_each_series) {
        [
          [
            'The correspondence in the collection consist of letters and postcards.',
            'Correspondents include: James Joyce.',
            'Contains  document allowing Bunshaft to practice architecture in Belgium.'
          ],
          [
            'The drawings in the collection consist of pencil and ink drawings.',
            'Artists include: H.J. Heinz.',
            'Contains blueprints for Bunshaft architecture in Belgium.'
          ]
        ]
      }

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

      let (:expected_series_subseries_compound_titles_hash) {
        {
          'Series I: Cataloged Correspondence, 1914-1989, 1894-1967, bulk 1958-1980' =>
          [
            'Subseries 1: Cataloged Correspondence -- Letters, 1914-1915, 1894-1960, bulk 1958-1960',
            'Subseries 2: Cataloged Correspondence - Postcards, 1914-1916, 1894-1961, bulk 1958-1961'
          ],
          'Series II: Cataloged Drawings, 1914-1989, 1897-1967, bulk 1958-1980' =>
          [
            'Subseries 1: Cataloged Drawings -- Sketches, 1914-1920, 1894-1970, bulk 1958-1970',
            'Subseries 2: Cataloged Drawings -- Blueprints, 1914-1940, 1894-1980, bulk 1958-1980'
          ]
        }
      }

      context 'given 2 series with 2 subseries each' do
        it "sets the scope_content_values_for_each_series attribute correctly" do
          values = @arch_desc_dsc_parser.scope_content_values_for_each_series
          expect(values.size).to eq expected_scope_content_values_for_each_series.size
          expected_scope_content_values_for_each_series.each_with_index do |expected_scope_content_array, i|
            expected_scope_content_array.each_with_index do |expected_scope_content, j|
              expect(values[i][j].text).to eq expected_scope_content
            end
          end
        end
      end

      context 'given 2 series with 2 subseries each' do
        it "sets the series_subseries_compound_title_hash correctly" do
          series_subseries_hash = @arch_desc_dsc_parser.series_subseries_compound_titles_hash
          expect(series_subseries_hash.size).to eq expected_series_subseries_compound_titles_hash.size
          expected_series_subseries_compound_titles_hash.each do |expected_series_compound_title, expected_subseries_compound_titles_array|
            expect(series_subseries_hash).to have_key(expected_series_compound_title)
            subseries_compound_titles_array = series_subseries_hash[expected_series_compound_title]
            expect(subseries_compound_titles_array).to eq expected_subseries_compound_titles_array
          end
        end
      end

      context 'given 2 series with 2 subseries each' do
        it "sets the subseries_compound_title_array_for_each_series_array attribute correctly" do
          values = @arch_desc_dsc_parser.subseries_compound_title_array_for_each_series_array
          expect(values.size).to eq expected_subseries_compound_title_array_for_each_series_array.size
          expected_subseries_compound_title_array_for_each_series_array.each_with_index do |subseries_compound_title_array, i|
            expect(values[i].size).to eq subseries_compound_title_array.size
            subseries_compound_title_array.each_with_index do |subseries_compound_title, j|
              expect(values[i][j]).to eq expected_subseries_compound_title_array_for_each_series_array[i][j]
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
    end
  end
end

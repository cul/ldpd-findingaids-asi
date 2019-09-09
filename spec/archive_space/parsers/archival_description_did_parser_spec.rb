require 'rails_helper'
require 'archive_space/parsers/archival_description_did_parser.rb'

all_attributes = [
  :abstracts, # <ead>:<archdesc>:<did>:<abstract>
  :language, # <ead>:<archdesc>:<did>:<langmaterial><language>
  :origination_creators, # <ead>:<archdesc>:<did>:<origination label="creator">
  :physical_description_extents_string, # <ead>:<archdesc>:<did>:<physdesc>:<extent>, formatted string
  :repository_corporate_name, # <ead><archdesc>:<did>:<repository>:<corpname>
  :unit_dates_string, # <ead>:<archdesc>:<did>:<unitdate>
  :unit_id_bib_id, # <ead>:<archdesc>:<did>:<unitid>, first instance
  :unit_id_call_number, # <ead>:<archdesc>:<did>:<unitid>, second instance, optional
  :unit_title # <ead>:<archdesc>:<did>:<unititle>
].freeze

single_value_attributes = [
  :language,
  :physical_description_extents_string,
  :repository_corporate_name,
  :unit_dates_string,
  :unit_id_bib_id,
  :unit_id_call_number,
  :unit_title
].freeze

# following is a subset of the above array
attributes_tested_individually = [
  :abstracts
].freeze



RSpec.describe ArchiveSpace::Parsers::ArchivalDescriptionDidParser do
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
      @arch_desc_did_parser = ArchiveSpace::Parsers::ArchivalDescriptionDidParser.new
      @arch_desc_did_parser.parse nokogiri_xml_document
    end

    ########################################## parse_arch_desc_misc
    describe 'method #parse' do
      let (:expected_abstracts) {
        [
          'This collection is made up of architectural drawings.',
          'This collection is also made up of architectural photographs.'
        ]
      }

      let (:expected_language) {
        'Material is in English and in French, with some materials in Dutch.'
      }

      let (:expected_origination_creators) {
        [
            "Columbia University. Teachers College",
            "Romanov family",
            "Sassoon, Siegfried, 1886-1967"
        ]
      }

      let (:expected_physical_description_extents_string) {
        ["3 linear feet (4 boxes 13 slipcases);",
         "3.6 Tb Digital (one hard disk);",
         "423 linear feet (351 record cartons 15 document boxes and 4 flat boxes)"
        ].join ' '
      }

      let (:expected_repository_corporate_name) {
        'Rare Book and Manuscript Library'
      }

      let (:expected_unit_dates_string) {
        '1914-1989, 1894-1966, bulk 1958-1980'
      }

      let (:expected_unit_id_bib_id) {
        '4079591'
      }

      let (:expected_unit_id_call_number) {
        'MS#0030'
      }

      let (:expected_unit_title) {
        'Siegfried Sassoon papers'
      }

      context 'abstract' do
        it 'sets the abstract attribute correctly' do
          values = @arch_desc_did_parser.abstracts
          expected_abstracts.each_with_index do |expected_abstract, index|
            expect(values[index].text).to eq expected_abstract
          end
        end
      end

      context 'sets correctly attributes that return an array:' do
        (all_attributes - single_value_attributes - attributes_tested_individually).each do |attribute|
          it "sets the #{attribute} attribute correctly" do
            expected_values = eval "expected_#{attribute}"
            expected_values.each_with_index do |expected_value, index|
              expect(@arch_desc_did_parser.instance_variable_get("@#{attribute}")[index]).to eq expected_value
            end
          end
        end
      end

      context 'sets correctly attributes that return an single value:' do
        (single_value_attributes - attributes_tested_individually).each do |attribute|
          it "sets the #{attribute} attribute correctly" do
            expected_value = eval "expected_#{attribute}"
            expect(@arch_desc_did_parser.instance_variable_get("@#{attribute}")).to eq expected_value
          end
        end
      end
    end
  end
end

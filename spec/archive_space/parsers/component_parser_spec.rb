require 'rails_helper'
require 'archive_space/parsers/component_parser.rb'

attributes = [
  # Note on comments: <a>:<b>:<c> means <c> elements that are direct children of <b> which
  # themselves are direct children of <a>
#  :accruals_head, # <ead>:<archdesc>:<dsc>:<c>:<accruals>:<head>
#  :accruals_values, # <ead>:<archdesc>:<dsc>:<c>:<accruals>:<p>
  :alternative_form_available_head, # <ead>:<archdesc>:<dsc>:<c>:<altformavail>:<head>
  :alternative_form_available_values, # <ead>:<archdesc>:<dsc>:<c>:<altformavail>:<p>
  :acquisition_information_head, # <ead>:<archdesc>:<dsc>:<c>:<acqinfo>:<head>
  :acquisition_information_values, # <ead>:<archdesc>:<dsc>:<c>:<acqinfo>:<p>
  :arrangement_head, # <ead>:<archdesc>:<dsc>:<c>:<arrangement>:<head>
  :arrangement_values, # <ead>:<archdesc>:<dsc>:<c>:<arrangement>:<p>
  :biography_or_history_head, # <ead>:<archdesc>:<dsc>:<c>:<bioghist>:<head>
  :biography_or_history_values, # <ead>:<archdesc>:<dsc>:<c>:<bioghist>:<p>
  :conditions_governing_access_head, # <ead>:<archdesc>:<dsc>:<c>:<accessrestrict>:<head>
  :conditions_governing_access_values, # <ead>:<archdesc>:<dsc>:<c>:<accessrestrict>:<p>
  :conditions_governing_use_head, # <ead>:<archdesc>:<dsc>:<c>:<accessrestrict>:<head>
  :conditions_governing_use_values, # <ead>:<archdesc>:<dsc>:<c>:<accessrestrict>:<p>
  :custodial_history_head, # <ead>:<archdesc>:<dsc>:<c>:<custodhist>:<head>
  :custodial_history_values, # <ead>:<archdesc>:<dsc>:<c>:<custodhist>:<p>
  :digital_archival_objects, # <ead>:<archdesc>:<dsc>:<c>:<did>:<dao>
  :other_descriptive_data_head, # <ead>:<archdesc>:<dsc>:<c>:<odd>:<head>
  :other_descriptive_data_values, # <ead>:<archdesc>:<dsc>:<c>:<odd>:<p>
  :other_finding_aid_head, # <ead>:<archdesc>:<dsc>:<c>:<otherfindaid>:<head>
  :other_finding_aid_values, # <ead>:<archdesc>:<dsc>:<c>:<otherfindaid>:<p>
#  :preferred_citation_head, # <ead>:<archdesc>:<dsc>:<c>:<prefercite>:<head>
#  :preferred_citation_values, # <ead>:<archdesc>:<dsc>:<c>:<prefercite>:<p>
#  :processing_information_head, # <ead>:<archdesc>:<dsc>:<c>:<processinfo>:<head>
#  :processing_information_values, # <ead>:<archdesc>:<dsc>:<c>:<processinfo>:<p>
  :related_material_head, # <ead>:<archdesc>:<dsc>:<c>:<relatedmaterial>:<head>
  :related_material_values, # <ead>:<archdesc>:<dsc>:<c>:<related_material>:<p>
  :scope_and_content_head, # <ead>:<archdesc>:<dsc>:<c>:<scopecontent>:<head>
  :scope_and_content_values, # <ead>:<archdesc>:<dsc>:<c>:<scopecontent>:<p>
  :separated_material_head, # <ead>:<archdesc>:<dsc>:<c>:<separatedmaterial>:<head>
  :separated_material_values # <ead>:<archdesc>:<dsc>:<c>:<separatedmaterial>:<p>
].freeze

RSpec.describe ArchiveSpace::Parsers::ComponentParser do
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
        expect(subject).to respond_to(:parse).with(2).arguments
      end
    end
  end

  ########################################## Functionality
  describe 'Testing functionality: ' do
    before(:context) do
      xml_input = fixture_file_upload('ead/test_ead.xml').read
      nokogiri_xml_document = Nokogiri::XML(xml_input) do |config|
        config.norecover
      end
      @component_parser = ArchiveSpace::Parsers::ComponentParser.new
      @component_parser.parse(nokogiri_xml_document, 1)
    end

    ########################################## parse_arch_desc_misc
    context 'parse' do
      let (:expected_heads) {
        {
#          accruals_head: 'Accruals',
          alternative_form_available_head: 'Alternate Form Available',
          acquisition_information_head: 'Acquisition',
          arrangement_head: 'Arrangement',
          biography_or_history_head: 'Historical Note',
          conditions_governing_access_head: 'Conditions Governing Access',
          conditions_governing_use_head: 'Terms Governing Use and Reproduction',
          custodial_history_head: 'Custodial History',
          other_descriptive_data_head: 'General Note',
          other_finding_aid_head: 'Other Finding Aids',
          preferred_citation_head: 'Preferred Citation',
          processing_information_head: 'Processing Information',
          related_material_head: 'Related Materials',
          scope_and_content_head: 'Scope and Contents',
          separated_material_head: 'Separated Materials'
        }
      }
      
      let (:expected_alternative_form_available_values) {
        [
          'Microforms available.(AF)',
          'Photocopies available.(AF)',
          'Microfiche available.(AF)'
        ]
      }

      let (:expected_acquisition_information_values) {
        [
          'Transferred from NYPL(ACQ)',
          'Transferred from CUL(ACQ)',
          'Transferred from Metro(ACQ)'
        ]
      }

      let (:expected_arrangement_values) {
        [
          'Arranged alphabetically by subject.',
          'Arranged alphabetically by author.',
          'Arranged alphabetically by location.'
        ]
      }

      let (:expected_biography_or_history_values) {
        [
          'John ate pizza for lunch.(BH)',
          'John ate a burger for lunch.(BH)',
          'John ate fish for lunch.(BH)'
        ]
      }

       let (:expected_conditions_governing_access_values) {
        [
          '[Restricted Until 2039](top-level container)',
          '[Restricted Until 2059](top-level container)',
          '[Restricted Until 2020](top-level container)'
        ]
      }

      let (:expected_conditions_governing_use_values) {
        [
          'Five photocopies may be made for research purposes.(UR)',
          'One photocopy may be made for research purposes.(UR)',
          'Single photocopies may be made for research purposes.(UR)'
        ]
      }

      let (:expected_custodial_history_values) {
        [
          'Gift of the ABC Company, 1963.(CH)',
          'Gift of the BCD Company, 1963.(CH)',
          'Gift of the DDD Company, 1963.(CH)'
        ]
      }

      let (:expected_digital_archival_objects) {
        [
          {
            href: 'https://dlc.library.columbia.edu/ifp/search',
            description: 'Browse or Search Digital Materials'
          },
          {
            href: 'https://dlc.library.columbia.edu/ifp/partner/secretariat',
            description: 'Sub-subseries I.13.A: Secretariat Unrestricted Digital Files, 2001-2013'
          }
        ]
      }

      let (:expected_other_descriptive_data_values) {
        [
          'This collection is nice(ODD)',
          'This repo is nice(ODD)',
          'This series is nice(ODD)'
        ]
      }

      let (:expected_other_finding_aid_values) {
        [
          '*In addition, a sortable inventory in this downloadable Excel spreadsheet.',
          'A pdf version is available for download.',
          'Another finding aid available online.'
        ]
      }

      let (:expected_related_material_values) {
        [
          'The related memoirs are cataloged individually(RM)',
          'The related photographs are cataloged individually(RM)',
          'The related recordings are cataloged individually(RM)'
        ]
      }

      let (:expected_scope_and_content_values) {
        [
          'The correspondence in the collection consist of letters and postcards.',
          'Correspondents include: James Joyce.',
          'Contains  document allowing Bunshaft to practice architecture in Belgium.'
        ]
      }

      let (:expected_separated_material_values) {
        [
          "Some interviewees' personal papers were separated and described as their own collection.",
          'Oral history transcripts in this series are drafts and editing copies.',
          'The personal papers and finalized individual memoirs are cataloged in CLIO.'
        ]
      }

      it 'sets digital_archival_objects correctly' do
        digital_archival_objects = @component_parser.digital_archival_objects
        expect(expected_digital_archival_objects.size).to eq digital_archival_objects.size
        expected_digital_archival_objects.each_with_index do |expected_digital_archival_object, index|
          expect(digital_archival_objects[index].href).to eq expected_digital_archival_object[:href]
          expect(digital_archival_objects[index].description).to eq expected_digital_archival_object[:description]
        end
      end

      head_attributes = attributes.find_all { |attribute| "#{attribute}".ends_with? "head"}
      head_attributes.each do |head_attribute|
        it "sets the attribute #{head_attribute} correctly" do
          expected_head = expected_heads[head_attribute]
          expect(@component_parser.instance_variable_get("@#{head_attribute}")).to eq expected_head
        end
      end

      value_attributes = attributes.find_all { |attribute| "#{attribute}".ends_with? "values"}
      value_attributes.each do |value_attribute|
        it "sets the attribute #{value_attribute} correctly" do
          expected_values = eval "expected_#{value_attribute}"
          expected_values.each_with_index do |expected_value, index|
            expect(@component_parser.instance_variable_get("@#{value_attribute}")[index].text).to eq expected_value
          end
        end
      end
    end
  end
end

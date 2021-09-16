require 'rails_helper'
require 'archive_space/parsers/archival_description_misc_parser.rb'
# fcd1, 09/09/19: TODO: Control Access test.

attributes = [
  :access_restrictions_head, # <ead>:<archdesc>:<accessrestrict>:<head>
  :access_restrictions_values, # <ead>:<archdesc>:<accessrestrict>:<p>
  :accruals_head, # <ead>:<archdesc>:<accruals>:<head>
  :accruals_values, # <ead>:<archdesc>:<accruals>:<p>
  :acquisition_information_head, # <ead>:<archdesc>:<acqinfo>:<head>
  :acquisition_information_values, # <ead>:<archdesc>:<acqinfo>:<p>
  :alternative_form_available_head, # <ead>:<archdesc>:<altformavail>:<head>
  :alternative_form_available_values, # <ead>:<archdesc>:<altformavail>:<p>
  :appraisal_information_head, # <ead>:<archdesc>:<appraisal>:<head>
  :appraisal_information_values, # <ead>:<archdesc>:<appraisal>:<p>
  :arrangement_head, # <ead>:<archdesc>:<arrangement>:<head>
  :arrangement_values, # <ead>:<archdesc>:<arrangement>:<p>
  :biography_history_head, # <ead>:<archdesc>:<bioghist>:<head>
  :biography_history_values, # <ead>:<archdesc>:<bioghist>:<p>
  :control_access_corporate_name_values, # <ead>:<archdesc>:<controlaccess>:<corpname>
  :control_access_genre_form_values, # <ead>:<archdesc>:<controlaccess>:<genreform>
  :control_access_geographic_name_values, # <ead>:<archdesc>:<controlaccess>:<geogname>
  :control_access_occupation_values, # <ead>:<archdesc>:<controlaccess>:<occupation>
  :control_access_personal_name_values, # <ead>:<archdesc>:<controlaccess>:<persname>
  :control_access_subject_values, # <ead>:<archdesc>:<controlaccess>:<subject>
  :conditions_governing_use_head, # <ead>:<archdesc>:<userestrict>:<head>
  :conditions_governing_use_values, # <ead>:<archdesc>:<userestrict>:<p>
  :custodial_history_head, # <ead>:<archdesc>:<custodhist>:<head>
  :custodial_history_values, # <ead>:<archdesc>:<custodhist>:<p>
  :other_descriptive_data_head, # <ead>:<archdesc>:<odd>:<head>
  :other_descriptive_data_values, # <ead>:<archdesc>:<odd>:<p>
  :other_finding_aid_head, # <ead>:<archdesc>:<otherfindaid>:<head>
  :other_finding_aid_values, # <ead>:<archdesc>:<otherfindaid>:<p>
  :preferred_citation_head, # <ead>:<archdesc>:<prefercite>:<head>
  :preferred_citation_values, # <ead>:<archdesc>:<prefercite>:<p>
  :processing_information_head, # <ead>:<archdesc>:<processinfo>:<head>
  :processing_information_values, # <ead>:<archdesc>:<processinfo>:<p>
  :related_material_head, # <ead>:<archdesc>:<relatedmaterial>:<head>
  :related_material_values, # <ead>:<archdesc>:<related_material>:<p>
  :scope_and_content_head, # <ead>:<archdesc>:<scopecontent>:<head>
  :scope_and_content_values, # <ead>:<archdesc>:<scopecontent>:<p>
  :separated_material_head, # <ead>:<archdesc>:<separatedmaterial>:<head>
  :separated_material_values # <ead>:<archdesc>:<separatedmaterial>:<p>
].freeze

# following is a subset of the attributes array. The control access
# attributes are tested differently -- no need to call the .text
# method on them, contents are already text
control_access_attributes = [
  :control_access_corporate_name_values,
  :control_access_genre_form_values,
  :control_access_geographic_name_values,
  :control_access_occupation_values,
  :control_access_personal_name_values,
  :control_access_subject_values
].freeze

RSpec.describe ArchiveSpace::Parsers::ArchivalDescriptionMiscParser do
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
        expect(subject).to respond_to(:parse).with(1).arguments
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
      @arch_desc_misc_parser = ArchiveSpace::Parsers::ArchivalDescriptionMiscParser.new
      @arch_desc_misc_parser.parse nokogiri_xml_document
    end

    ########################################## parse_arch_desc_misc
    context 'parse' do
      let (:expected_heads) {
        {
          access_restrictions_head: 'Restrictions on Access',
          accruals_head: 'Accruals',
          acquisition_information_head: 'Immediate Source of Acquisition',
          alternative_form_available_head: 'Alternate Form Available',
          appraisal_information_head: 'Appraisal',
          arrangement_head: 'Arrangement',
          biography_history_head: 'Biographical note',
          conditions_governing_use_head: 'Terms Governing Use and Reproduction',
          custodial_history_head: 'Custodial History',
          other_descriptive_data_head: 'General Note',
          other_finding_aid_head: 'Other Finding Aids',
          preferred_citation_head: 'Preferred Citation',
          processing_information_head: 'Processing Information',
          related_material_head: 'Related Materials',
          scope_and_content_head: 'Scope and Content',
          separated_material_head: 'Separated Materials'
        }
      }
      
      let (:expected_access_restrictions_head) {
        [
          "This collection is located on-site.",
          "This collection has no restrictions."
        ]
      }

      let (:expected_access_restrictions_values) {
        [
          "This collection is located on-site.",
          "This collection has no restrictions."
        ]
      }

      let (:expected_accruals_values) {
        [
          "No additional material is expected in the short term.",
          "Additional material is expected in the long term."
        ]
      }

      let (:expected_acquisition_information_values) {
        [
          "The collection was donated to the RBML by a Nice Donor.",
          "The collection was delivered at the specified time."
        ]
      }

      let (:expected_alternative_form_available_values) {
        [
          "Selected manuscripts are on: microfilm.",
          "Selected manuscripts are on: microfiche."
        ]
      }

      let (:expected_appraisal_information_values) {
        [
          "Clippings from widely available English language newspapers.",
          "Clippings from widely available French language newspapers."
        ]
      }

      let (:expected_arrangement_values) {
        [
          "Selected materials cataloged.",
          "Remainder arranged."
        ]
      }

      let (:expected_biography_history_values) {
        [
          "Siegfried Loraine Sassoon, CBE, MC was an English poet, writer, and soldier.",
          "Decorated for bravery on the Western Front."
        ]
      }

      let (:expected_control_access_corporate_name_values) {
        [
          "Barnard College",
          "Simon and Schuster, Inc"
        ]
      }

      let (:expected_control_access_genre_form_values) {
        [
          "Illustrations",
          "Initials"
        ]
      }

      let (:expected_control_access_geographic_name_values) {
        [
          "Russia -- History -- 1801-1917",
          "Belgium -- History -- 1914-1918"
        ]
      }

      let (:expected_control_access_occupation_values) {
        [
          "Artists",
          "Cartoonists"
        ]
      }

      let (:expected_control_access_personal_name_values) {
        [
          "Fritz, Chester",
          "Tong, Te-kong, 1920-2009"
        ]
      }

      let (:expected_control_access_subject_values) {
        [
          "Art",
          "Drawing"
        ]
      }

      let (:expected_conditions_governing_use_values) {
        [
          "Readers must use microfilm of materials specified above.",
          "Single photocopies may be made for research purposes."
        ]
      }

      let (:expected_custodial_history_values) {
        [
          "Gift of the ABC Company, 1963.(CH)",
          "Gift of the BCD Company, 1963.(CH)"
        ]
      }

      let (:expected_preferred_citation_values) {
        [
          "Identification of specific item.",
          "Date and Provenance of specific item."
        ]
      }

      let (:expected_other_descriptive_data_values) {
        [
          "Other collections of Rockwell Kent materials are at: SUNY-Plattsburgh (Rockwell Kent Collection).",
          "This is the collection-level record for which 700 associated project-level records were created."
        ]
      }

      let (:expected_other_finding_aid_values) {
        [
          "Use the CDLI (https://cdli.ucla.edu/) to identify tablets by date, genre, etc.",
          "Use CLIO to search for other finding aids."
        ]
      }

      let (:expected_processing_information_values) {
        [
          "Papers Entered in AMC 11/29/1990.",
          "4 letters of Arnold Bennett Cataloged HR 11/25/1991."
        ]
      }

      let (:expected_related_material_values) {
        [
          "The following are the finalized memoirs are cataloged individually:",
          "Reminiscences of Choy Jun-ke"
        ]
      }

      let (:expected_scope_and_content_values) {
        [
          "The Edith Elmer Wood Collection covers a short but important period in the housing field.",
          "The collection documents this period."
        ]
      }

      let (:expected_separated_material_values) {
        [
          "Interviewees' personal papers were separated.",
          "Researchers may find the personal papers on CLIO."
        ]
      }

      head_attributes = attributes.find_all { |attribute| "#{attribute}".ends_with? "head"}
      head_attributes.each do |head_attribute|
        it "sets the attribute #{head_attribute} correctly" do
          expected_head = expected_heads[head_attribute]
          expect(@arch_desc_misc_parser.instance_variable_get("@#{head_attribute}")).to eq expected_head
        end
      end

      value_attributes = attributes.find_all { |attribute| "#{attribute}".ends_with? "values"} - control_access_attributes
      value_attributes.each do |value_attribute|
        it "sets the attribute #{value_attribute} correctly" do
          expected_values = eval "expected_#{value_attribute}"
          expected_values.each_with_index do |expected_value, index|
            expect(@arch_desc_misc_parser.instance_variable_get("@#{value_attribute}")[index].text).to eq expected_value
          end
        end
      end

      # Following tested separately because no need to use '.text' on the values
      control_access_attributes.each do |control_access_attribute|
        it "sets the attribute #{control_access_attribute} correctly" do
          expected_values = eval "expected_#{control_access_attribute}"
          expected_values.each_with_index do |expected_value, index|
            expect(@arch_desc_misc_parser.instance_variable_get("@#{control_access_attribute}")[index]).to eq expected_value
          end
        end
      end
    end
  end
end

# Encoded Archival Description (EAD) element: <archdesc> Archival Description
# EAD specs: https://www.loc.gov/ead/index.html
require 'rails_helper'
require 'ead/elements/archdesc.rb'

# Ead::Elements::Archdesc is derived from
# Ead::Elements::ArchdescComponentCommonality, which defines the following
# class methods. NOTE: only the class methods currently used by the app to
# parse a <archdesc> element are listed here.
common_class_methods = [
  :accessrestrict_head_array, # <accessrestrict><head>
  :accessrestrict_p_array, # <accessrestrict><p>
  :accruals_head_array, # <accruals><head>
  :accruals_p_array, # <accruals><p>
  :altformavail_head_array,  # <altformavail><head>
  :altformavail_p_array, # <altformavail><p>
  :arrangement_head_array, # <arrangement><head>
  :arrangement_p_array, # <arrangement><p>
  :bioghist_head_array, # <bioghist><head>
  :bioghist_p_array, # <bioghist><p>
  :controlaccess_array, # <controlaccess>
  :did, # <did>
  :dsc, # <dsc>
  :odd_head_array, # <odd><head>
  :odd_p_array, # <odd><p>
  :otherfindaid_head_array, # <otherfindaid><head>
  :otherfindaid_p_array, # <otherfindaid><p>
  :prefercite_head_array, # <prefercite><head>
  :prefercite_p_array, # <prefercite><p>
  :processinfo_head_array, # <processinfo><head>
  :processinfo_p_array, # <processinfo><p>
  :relatedmaterial_head_array, # <relatedmaterial><head>
  :relatedmaterial_p_array, # <relatedmaterial><p>
  :scopecontent_head_array, # <scopecontent><head>
  :scopecontent_p_array, # <scopecontent><p>
  :separatedmaterial_head_array, # <separatedmaterial><head>
  :separatedmaterial_p_array, # <separatedmaterial><p>
  :userestrict_head_array, # <userestrict><head>
  :userestrict_p_array # <userestrict><p>
].freeze

RSpec.describe Ead::Elements::Archdesc do
  ########################################## API/interface
  describe '-- Validate API/interface --' do
    context 'has class method' do
      common_class_methods.each do |class_method|
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
      @nokogiri_node_set = Nokogiri::XML(input_xml).xpath('/xmlns:ead/xmlns:archdesc')
    end

    describe ' class methods that return an array of composite elements:' do
      # <controlaccess> Controlled Access Headings
      context 'class method controlaccess_array' do
        it 'takes an <archdesc> and returns an array of <controlaccess>' do
          controlaccess_array = Ead::Elements::Archdesc.controlaccess_array(@nokogiri_node_set)
          expect(controlaccess_array.first).to be_instance_of Nokogiri::XML::Element
          expect(controlaccess_array.first.name).to eq 'controlaccess'
        end
      end

      # <did> Descriptive Identification
      context 'class method did' do
        it 'takes an <archdesc> and returns the <did>' do
          did = Ead::Elements::Archdesc.did(@nokogiri_node_set)
          expect(did).to be_instance_of Nokogiri::XML::Element
          expect(did.name).to eq 'did'
        end
      end

      # <dsc> Description of Subordinate Components
      context 'class method dsc' do
        it 'takes an <archdesc> and returns a <dsc>' do
          dsc = Ead::Elements::Archdesc.dsc(@nokogiri_node_set)
          expect(dsc).to be_instance_of Nokogiri::XML::Element
          expect(dsc.name).to eq 'dsc'
        end
      end
    end

    describe ' class methods that return an array:' do
      context 'class method' do
        # <accessrestrict> Conditions Governing Access
        let (:expected_accessrestrict_head_array) {
	  [
            "Restrictions on Access",
            "Restrictions on Access"
	  ]
        }
        let (:expected_accessrestrict_p_array) {
	  [
            "This collection is located on-site.",
            "This collection has no restrictions."
	  ]
        }

        # <accruals> Accruals
        let (:expected_accruals_head_array) {
	  [
            "Accruals",
            "Accruals"
	  ]
        }
        let (:expected_accruals_p_array) {
	  [
            "No additional material is expected in the short term.",
            "Additional material is expected in the long term."
	  ]
        }

        # <altformavail> Alternative Form Available
        let (:expected_altformavail_head_array) {
	  [
            "Alternate Form Available",
            "Alternate Form Available"
	  ]
        }
        let (:expected_altformavail_p_array) {
	  [
            "Selected manuscripts are on: microfilm.",
            "Selected manuscripts are on: microfiche."
	  ]
        }

        # <arrangement> Arrangement
        let (:expected_arrangement_head_array) {
	  [
            "Arrangement",
            "Arrangement"
	  ]
        }
        let (:expected_arrangement_p_array) {
	  [
            "Selected materials cataloged.",
            "Remainder arranged."
	  ]
        }

        # <bioghist> Biography or History
        let (:expected_bioghist_head_array) {
	  [
            "Biographical note",
            "Biographical note"
	  ]
        }
        let (:expected_bioghist_p_array) {
	  [
            "Siegfried Loraine Sassoon, CBE, MC was an English poet, writer, and soldier.",
            "Decorated for bravery on the Western Front."
	  ]
        }

        # <odd> Other Descriptive Data
        let (:expected_odd_head_array) {
	  [
            "General Note",
            "General Note"
	  ]
        }
        let (:expected_odd_p_array) {
	  [
            "Other collections of Rockwell Kent materials are at: SUNY-Plattsburgh (Rockwell Kent Collection).",
            "This is the collection-level record for which 700 associated project-level records were created."
	  ]
        }

        # <otherfindaid> Other Finding Aid
        let (:expected_otherfindaid_head_array) {
	  [
            "Other Finding Aids",
            "Other Finding Aids"
	  ]
        }
        let (:expected_otherfindaid_p_array) {
	  [
            "Use the CDLI (https://cdli.ucla.edu/) to identify tablets by date, genre, etc.",
            "Use CLIO to search for other finding aids."
	  ]
        }

        # <prefercite> Preferred Citation
        let (:expected_prefercite_head_array) {
	  [
            "Preferred Citation",
            "Preferred Citation"
	  ]
        }
        let (:expected_prefercite_p_array) {
	  [
            "Identification of specific item.",
            "Date and Provenance of specific item."
	  ]
        }

        # <processinfo> Processing Information
        let (:expected_processinfo_head_array) {
	  [
            "Processing Information",
            "Processing Information"
	  ]
        }
        let (:expected_processinfo_p_array) {
	  [
            "Papers Entered in AMC 11/29/1990.",
            "4 letters of Arnold Bennett Cataloged HR 11/25/1991."
	  ]
        }

        # <relatedmaterial> Related Material
        let (:expected_relatedmaterial_head_array) {
	  [
            "Related Materials",
            "Related Materials"
	  ]
        }
        let (:expected_relatedmaterial_p_array) {
	  [
            "The following are the finalized memoirs are cataloged individually:",
            "Reminiscences of Choy Jun-ke"
	  ]
        }

        # <scopecontent> Scope and Content
        let (:expected_scopecontent_head_array) {
	  [
            "Scope and Content",
            "Scope and Content"            
	  ]
        }
        let (:expected_scopecontent_p_array) {
	  [
            "The Edith Elmer Wood Collection covers a short but important period in the housing field.",
            "The collection documents this period."            
	  ]
        }

        # <separatedmaterial> Separated Material
        let (:expected_separatedmaterial_head_array) {
	  [
            "Separated Materials",
            "Separated Materials"
	  ]
        }
        let (:expected_separatedmaterial_p_array) {
	  [
            "Interviewees' personal papers were separated.",
            "Researchers may find the personal papers on CLIO."
	  ]
        }

        # <userestrict> Conditions Governing Use
        let (:expected_userestrict_head_array) {
	  [
            "Terms Governing Use and Reproduction",
            "Terms Governing Use and Reproduction"
	  ]
        }
        let (:expected_userestrict_p_array) {
	  [
            "Readers must use microfilm of materials specified above.",
            "Single photocopies may be made for research purposes."
	  ]
        }

	array_class_methods = common_class_methods.find_all { |class_method| "#{class_method}".ends_with? "_array"}
        (array_class_methods - [:controlaccess_array]).each do |class_method|
          it ".#{class_method} takes a <did> and returns an array of <#{class_method.to_s.chomp('_array')}>" do
            values = Ead::Elements::Archdesc.send(class_method,@nokogiri_node_set)
            expected_values = eval "expected_#{class_method}"
            expected_values.each_with_index do |expected_value, index|
              expect(values[index].text).to eq expected_value
            end
          end
        end
      end
    end
  end
end

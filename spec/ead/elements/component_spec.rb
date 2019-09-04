# Encoded Archival Description (EAD) element: <archdesc> Archival Description
# EAD specs: https://www.loc.gov/ead/index.html
require 'rails_helper'
require 'ead/elements/component.rb'

# Ead::Elements::Component is derived from
# Ead::Elements::ArchdescComponentCommonality, which defines the following
# class methods. NOTE: only the class methods currently used by the app to
# parse a <c> element are listed here.
class_methods = [
  :accessrestrict_head_array, # <accessrestrict><head>
  :accessrestrict_p_array, # <accessrestrict><p>
  :altformavail_head_array,  # <altformavail><head>
  :altformavail_p_array, # <altformavail><p>
  :arrangement_head_array, # <arrangement><head>
  :arrangement_p_array, # <arrangement><p>
  :bioghist_head_array, # <bioghist><head>
  :bioghist_p_array, # <bioghist><p>
  :c_array, # <c>
  :did, # <did>
  :odd_head_array, # <odd><head>
  :odd_p_array, # <odd><p>
  :otherfindaid_head_array, # <otherfindaid><head>
  :otherfindaid_p_array, # <otherfindaid><p>
  :relatedmaterial_head_array, # <relatedmaterial><head>
  :relatedmaterial_p_array, # <relatedmaterial><p>
  :scopecontent_head_array, # <scopecontent><head>
  :scopecontent_p_array, # <scopecontent><p>
  :separatedmaterial_head_array, # <separatedmaterial><head>
  :separatedmaterial_p_array, # <separatedmaterial><p>
  :userestrict_head_array, # <userestrict><head>
  :userestrict_p_array # <userestrict><p>
].freeze

RSpec.describe Ead::Elements::Component do
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
      # test_ead_.xml contains two top-level <c> elements. Retrieve the first one as a test fixture
      @nokogiri_node_set = Nokogiri::XML(input_xml).xpath('/xmlns:ead/xmlns:archdesc/xmlns:dsc/xmlns:c').first
    end

    describe ' class methods that return an array of composite elements:' do
      # <did> Descriptive Identification
      context 'class method did' do
        it 'takes an <archdesc> and returns the <did>' do
          did = Ead::Elements::Component.did(@nokogiri_node_set)
          expect(did).to be_instance_of Nokogiri::XML::Element
          expect(did.name).to eq 'did'
        end
      end
    end

    describe ' class methods that return an array:' do
      context 'class method' do
        # <accessrestrict> Conditions Governing Access
        let (:expected_accessrestrict_head_array) {
	  [
            "Conditions Governing Access",
            "Conditions Governing Access",
            "Conditions Governing Access"
	  ]
        }
        let (:expected_accessrestrict_p_array) {
	  [
            "[Restricted Until 2039](top-level container)",
            "[Restricted Until 2059](top-level container)",
            "[Restricted Until 2020](top-level container)"            
	  ]
        }

        # <acqinfo> Acquisition Information
        let (:expected_acqinfo_head_array) {
	  [
            "Acquisition",
            "Acquisition",
            "Acquisition"
	  ]
        }
        let (:expected_acqinfo_p_array) {
	  [
            "Transferred from NYPL(ACQ)",
            "Transferred from CUL(ACQ)",
            "Transferred from Metro(ACQ)"
	  ]
        }

        # <altformavail> Alternative Form Available
        let (:expected_altformavail_head_array) {
	  [
            "Alternate Form Available",
            "Alternate Form Available",
            "Alternate Form Available"
	  ]
        }
        let (:expected_altformavail_p_array) {
	  [
            "Microforms available.(AF)",
            "Photocopies available.(AF)",
            "Microfiche available.(AF)"
	  ]
        }

        # <arrangement> Arrangement
        let (:expected_arrangement_head_array) {
	  [
            "Arrangement",
            "Arrangement",
            "Arrangement"
	  ]
        }
        let (:expected_arrangement_p_array) {
	  [
            "Arranged alphabetically by subject.",
            "Arranged alphabetically by author.",
            "Arranged alphabetically by location."
	  ]
        }

        # <bioghist> Biography or History
        let (:expected_bioghist_head_array) {
	  [
            "Historical Note",
            "Historical Note",
            "Historical Note"
	  ]
        }
        let (:expected_bioghist_p_array) {
	  [
            "John ate pizza for lunch.(BH)",
            "John ate a burger for lunch.(BH)",
            "John ate fish for lunch.(BH)"
	  ]
        }

        # <c><did><unittile>, used to validate retrieved <c> elements
        let (:expected_child_component_unittitles) {
	  [
            "Subseries 1: Cataloged Correspondence -- Letters",
            "Subseries 2: Cataloged Correspondence - Postcards"
	  ]
        }

        # <odd> Other Descriptive Data
        let (:expected_odd_head_array) {
	  [
            "General Note",
            "General Note",
            "General Note"
	  ]
        }
        let (:expected_odd_p_array) {
	  [
            "This collection is nice(ODD)",
            "This repo is nice(ODD)",
            "This series is nice(ODD)"
	  ]
        }

        # <otherfindaid> Other Finding Aid
        let (:expected_otherfindaid_head_array) {
	  [
            "Other Finding Aids",
            "Other Finding Aids",
            "Other Finding Aids"
	  ]
        }
        let (:expected_otherfindaid_p_array) {
	  [
            "*In addition, a sortable inventory in this downloadable Excel spreadsheet.",
            "A pdf version is available for download.",
            "Another finding aid available online."
	  ]
        }

        # <relatedmaterial> Related Material
        let (:expected_relatedmaterial_head_array) {
	  [
            "Related Materials",
            "Related Materials",
            "Related Materials"
	  ]
        }
        let (:expected_relatedmaterial_p_array) {
	  [
            "The related memoirs are cataloged individually(RM)",
            "The related photographs are cataloged individually(RM)",
            "The related recordings are cataloged individually(RM)"
	  ]
        }

        # <scopecontent> Scope and Content
        let (:expected_scopecontent_head_array) {
	  [
            "Scope and Contents",
            "Scope and Contents",
            "Scope and Contents"            
	  ]
        }
        let (:expected_scopecontent_p_array) {
	  [
            "The drawings in the collection consist of pencil and ink drawings.",
            "Correspondents include: H.J. Heinz.",
            "Contains  document allowing Bunshaft to practice architecture in Belgium."
	  ]
        }

        # <separatedmaterial> Separated Material
        let (:expected_separatedmaterial_head_array) {
	  [
            "Separated Materials",
            "Separated Materials",
            "Separated Materials"
	  ]
        }
        let (:expected_separatedmaterial_p_array) {
	  [
            "Some interviewees' personal papers were separated and described as their own collection.",
            "Oral history transcripts in this series are drafts and editing copies.",
            "The personal papers and finalized individual memoirs are cataloged in CLIO."
	  ]
        }

        # <userestrict> Conditions Governing Use
        let (:expected_userestrict_head_array) {
	  [
            "Terms Governing Use and Reproduction",
            "Terms Governing Use and Reproduction",
            "Terms Governing Use and Reproduction"
	  ]
        }
        let (:expected_userestrict_p_array) {
	  [
            "Five photocopies may be made for research purposes.(UR)",
            "One photocopy may be made for research purposes.(UR)",
            "Single photocopies may be made for research purposes.(UR)"
	  ]
        }

        # Testing .c_array functionality
        it '.c_array takes a <c> element and returns an array of <c> elements (the direct children that are <c> elements)' do
          child_components = Ead::Elements::Component.c_array(@nokogiri_node_set)
          expect(child_components.size).to eq expected_child_component_unittitles.size
          expected_child_component_unittitles.each_with_index do |expected_child_component_unittitle, index|
            expect(child_components[index].xpath('./xmlns:did/xmlns:unittitle').text).to eq expected_child_component_unittitle
          end
        end

        # NOTE: Testing the .c_array and .controlaccess_array functionality is more involved, so this functionality is not tested
        # in the following example. Instead, the functionality for these class methods is tested in separate examples
        array_class_methods = class_methods.find_all { |class_method| "#{class_method}".ends_with? "_array"}
        (array_class_methods - [:controlaccess_array, :c_array]).each do |class_method|
          it ".#{class_method} takes a <c> element and returns an array of <#{class_method.to_s.chomp('_array')}>" do
            values = Ead::Elements::Component.send(class_method,@nokogiri_node_set)
            expected_values = eval "expected_#{class_method}"
            expect(values.size).to eq expected_values.size
            expected_values.each_with_index do |expected_value, index|
              expect(values[index].text).to eq expected_value
            end
          end
        end
      end
    end
  end
end

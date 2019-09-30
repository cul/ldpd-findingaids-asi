# Encoded Archival Description (EAD) element: <archdesc> Archival Description
# EAD specs: https://www.loc.gov/ead/index.html
require 'rails_helper'
require 'ead/elements/component.rb'

# Ead::Elements::Component is derived from
# Ead::Elements::ArchdescComponentCommonality, which defines the following
# class methods. NOTE: only the class methods currently used by the app to
# parse a <c> element are listed here.
class_methods = [
  :accessrestrict_head_node_set, # <accessrestrict><head>
  :accessrestrict_p_node_set, # <accessrestrict><p>
  :altformavail_head_node_set,  # <altformavail><head>
  :altformavail_p_node_set, # <altformavail><p>
  :arrangement_head_node_set, # <arrangement><head>
  :arrangement_p_node_set, # <arrangement><p>
  :bioghist_head_node_set, # <bioghist><head>
  :bioghist_p_node_set, # <bioghist><p>
  :c_node_set, # <c>
  :c_level_attribute_subseries_node_set, # <c level="subseries">
  :did_node_set, # <did>
  :level_attribute_node_set, # <c level= >
  :odd_head_node_set, # <odd><head>
  :odd_p_node_set, # <odd><p>
  :otherfindaid_head_node_set, # <otherfindaid><head>
  :otherfindaid_p_node_set, # <otherfindaid><p>
  :relatedmaterial_head_node_set, # <relatedmaterial><head>
  :relatedmaterial_p_node_set, # <relatedmaterial><p>
  :scopecontent_head_node_set, # <scopecontent><head>
  :scopecontent_p_node_set, # <scopecontent><p>
  :separatedmaterial_head_node_set, # <separatedmaterial><head>
  :separatedmaterial_p_node_set, # <separatedmaterial><p>
  :userestrict_head_node_set, # <userestrict><head>
  :userestrict_p_node_set # <userestrict><p>
].freeze

# following is a subset of the above array
class_methods_tested_individually = [
  :c_node_set,
  :c_level_attribute_subseries_node_set,
  :controlaccess_node_set,
  :did_node_set
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
          did = Ead::Elements::Component.did_node_set(@nokogiri_node_set).first
          expect(did).to be_instance_of Nokogiri::XML::Element
          expect(did.name).to eq 'did'
        end
      end
    end

    describe ' class methods that return an array:' do
      context 'class method' do
        # <accessrestrict> Conditions Governing Access
        let (:expected_accessrestrict_head_node_set) {
	  [
            "Conditions Governing Access",
            "Conditions Governing Access",
            "Conditions Governing Access"
	  ]
        }
        let (:expected_accessrestrict_p_node_set) {
	  [
            "[Restricted Until 2039](top-level container)",
            "[Restricted Until 2059](top-level container)",
            "[Restricted Until 2020](top-level container)"            
	  ]
        }

        # <acqinfo> Acquisition Information
        let (:expected_acqinfo_head_node_set) {
	  [
            "Acquisition",
            "Acquisition",
            "Acquisition"
	  ]
        }
        let (:expected_acqinfo_p_node_set) {
	  [
            "Transferred from NYPL(ACQ)",
            "Transferred from CUL(ACQ)",
            "Transferred from Metro(ACQ)"
	  ]
        }

        # <altformavail> Alternative Form Available
        let (:expected_altformavail_head_node_set) {
	  [
            "Alternate Form Available",
            "Alternate Form Available",
            "Alternate Form Available"
	  ]
        }
        let (:expected_altformavail_p_node_set) {
	  [
            "Microforms available.(AF)",
            "Photocopies available.(AF)",
            "Microfiche available.(AF)"
	  ]
        }

        # <arrangement> Arrangement
        let (:expected_arrangement_head_node_set) {
	  [
            "Arrangement",
            "Arrangement",
            "Arrangement"
	  ]
        }
        let (:expected_arrangement_p_node_set) {
	  [
            "Arranged alphabetically by subject.",
            "Arranged alphabetically by author.",
            "Arranged alphabetically by location."
	  ]
        }

        # <bioghist> Biography or History
        let (:expected_bioghist_head_node_set) {
	  [
            "Historical Note",
            "Historical Note",
            "Historical Note"
	  ]
        }
        let (:expected_bioghist_p_node_set) {
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
            "Alan Alda Transcript",
            "Subseries 2: Cataloged Correspondence - Postcards"
	  ]
        }

        # <c level="subseries"><did><unittile>, used to validate retrieved <c level="subseries"> elements
        let (:expected_child_component_level_subseries_unittitles) {
	  [
            "Subseries 1: Cataloged Correspondence -- Letters",
            "Subseries 2: Cataloged Correspondence - Postcards"
	  ]
        }

        # <c level > level attribute
        let (:expected_level_attribute_node_set) {
	  [
            'series'
	  ]
        }

        # <odd> Other Descriptive Data
        let (:expected_odd_head_node_set) {
	  [
            "General Note",
            "General Note",
            "General Note"
	  ]
        }
        let (:expected_odd_p_node_set) {
	  [
            "This collection is nice(ODD)",
            "This repo is nice(ODD)",
            "This series is nice(ODD)"
	  ]
        }

        # <otherfindaid> Other Finding Aid
        let (:expected_otherfindaid_head_node_set) {
	  [
            "Other Finding Aids",
            "Other Finding Aids",
            "Other Finding Aids"
	  ]
        }
        let (:expected_otherfindaid_p_node_set) {
	  [
            "*In addition, a sortable inventory in this downloadable Excel spreadsheet.",
            "A pdf version is available for download.",
            "Another finding aid available online."
	  ]
        }

        # <relatedmaterial> Related Material
        let (:expected_relatedmaterial_head_node_set) {
	  [
            "Related Materials",
            "Related Materials",
            "Related Materials"
	  ]
        }
        let (:expected_relatedmaterial_p_node_set) {
	  [
            "The related memoirs are cataloged individually(RM)",
            "The related photographs are cataloged individually(RM)",
            "The related recordings are cataloged individually(RM)"
	  ]
        }

        # <scopecontent> Scope and Content
        let (:expected_scopecontent_head_node_set) {
	  [
            "Scope and Contents",
            "Scope and Contents",
            "Scope and Contents"            
	  ]
        }
        let (:expected_scopecontent_p_node_set) {
	  [
            "The correspondence in the collection consist of letters and postcards.",
            "Correspondents include: James Joyce.",
            "Contains  document allowing Bunshaft to practice architecture in Belgium."
	  ]
        }

        # <separatedmaterial> Separated Material
        let (:expected_separatedmaterial_head_node_set) {
	  [
            "Separated Materials",
            "Separated Materials",
            "Separated Materials"
	  ]
        }
        let (:expected_separatedmaterial_p_node_set) {
	  [
            "Some interviewees' personal papers were separated and described as their own collection.",
            "Oral history transcripts in this series are drafts and editing copies.",
            "The personal papers and finalized individual memoirs are cataloged in CLIO."
	  ]
        }

        # <userestrict> Conditions Governing Use
        let (:expected_userestrict_head_node_set) {
	  [
            "Terms Governing Use and Reproduction",
            "Terms Governing Use and Reproduction",
            "Terms Governing Use and Reproduction"
	  ]
        }
        let (:expected_userestrict_p_node_set) {
	  [
            "Five photocopies may be made for research purposes.(UR)",
            "One photocopy may be made for research purposes.(UR)",
            "Single photocopies may be made for research purposes.(UR)"
	  ]
        }

        # Testing .c_node_set functionality
        it '.c_node_set takes a <c> element and returns an array of <c> elements (the direct children that are <c> elements)' do
          child_components = Ead::Elements::Component.c_node_set(@nokogiri_node_set)
          expect(child_components.size).to eq expected_child_component_unittitles.size
          expected_child_component_unittitles.each_with_index do |expected_child_component_unittitle, index|
            expect(child_components[index].xpath('./xmlns:did/xmlns:unittitle').text).to eq expected_child_component_unittitle
          end
        end

        # Testing .c_level_attribute_subseries_node_set functionality
        it '.c_level_attribute_subseries_node_set takes a <c> element and returns an array of <c level="subseries"> elements (direct children)' do
          child_subseries_components = Ead::Elements::Component.c_level_attribute_subseries_node_set(@nokogiri_node_set)
          expect(child_subseries_components.size).to eq expected_child_component_level_subseries_unittitles.size
          expected_child_component_level_subseries_unittitles.each_with_index do |expected_child_component_level_subseries_unittitle, index|
            expect(child_subseries_components[index].xpath('./xmlns:did/xmlns:unittitle').text).to eq expected_child_component_level_subseries_unittitle
          end
        end

        # NOTE: Testing the class methods in the class_methods_tested_individually array is more involved, so the functionality
        # is not tested in the following example. Instead, the functionality for these class methods is tested in separate examples
        node_set_class_methods = class_methods.find_all { |class_method| "#{class_method}".ends_with? "_node_set"}
        (node_set_class_methods - class_methods_tested_individually).each do |class_method|
          it ".#{class_method} takes a <c> element and returns a Nokogiri::XML::NodeSet of <#{class_method.to_s.chomp('_node_set')}>" do
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

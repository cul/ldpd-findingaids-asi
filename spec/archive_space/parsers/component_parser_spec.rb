require 'rails_helper'
require 'archive_space/parsers/component_parser.rb'

attributes = [
  # Note on comments: <a>:<b>:<c> means <c> elements that are direct children of <b> which
  # themselves are direct children of <a>
#  :accruals_head, # <ead>:<archdesc>:<dsc>:<c>:<accruals>:<head>
#  :accruals_values, # <ead>:<archdesc>:<dsc>:<c>:<accruals>:<p>
  :acquisition_information_head, # <ead>:<archdesc>:<dsc>:<c>:<acqinfo>:<head>
  :acquisition_information_values, # <ead>:<archdesc>:<dsc>:<c>:<acqinfo>:<p>
  :alternative_form_available_head, # <ead>:<archdesc>:<dsc>:<c>:<altformavail>:<head>
  :alternative_form_available_values, # <ead>:<archdesc>:<dsc>:<c>:<altformavail>:<p>
  :arrangement_head, # <ead>:<archdesc>:<dsc>:<c>:<arrangement>:<head>
  :arrangement_values, # <ead>:<archdesc>:<dsc>:<c>:<arrangement>:<p>
  :biography_or_history_head, # <ead>:<archdesc>:<dsc>:<c>:<bioghist>:<head>
  :biography_or_history_values, # <ead>:<archdesc>:<dsc>:<c>:<bioghist>:<p>
  :compound_title_string, # string based on <unittitle> and <unitdate> elements
  :conditions_governing_access_head, # <ead>:<archdesc>:<dsc>:<c>:<accessrestrict>:<head>
  :conditions_governing_access_values, # <ead>:<archdesc>:<dsc>:<c>:<accessrestrict>:<p>
  :conditions_governing_use_head, # <ead>:<archdesc>:<dsc>:<c>:<accessrestrict>:<head>
  :conditions_governing_use_values, # <ead>:<archdesc>:<dsc>:<c>:<accessrestrict>:<p>
  :container_info_barcode, # see ACFA-176
  :container_info_strings, # array of container info strings
  :custodial_history_head, # <ead>:<archdesc>:<dsc>:<c>:<custodhist>:<head>
  :custodial_history_values, # <ead>:<archdesc>:<dsc>:<c>:<custodhist>:<p>
  :digital_archival_objects, # <ead>:<archdesc>:<dsc>:<c>:<did>:<dao>
  :flattened_component_tree_structure,
  :level_attribute,
  :other_descriptive_data_head, # <ead>:<archdesc>:<dsc>:<c>:<odd>:<head>
  :other_descriptive_data_values, # <ead>:<archdesc>:<dsc>:<c>:<odd>:<p>
  :other_finding_aid_head, # <ead>:<archdesc>:<dsc>:<c>:<otherfindaid>:<head>
  :other_finding_aid_values, # <ead>:<archdesc>:<dsc>:<c>:<otherfindaid>:<p>
#  :preferred_citation_head, # <ead>:<archdesc>:<dsc>:<c>:<prefercite>:<head>
#  :preferred_citation_values, # <ead>:<archdesc>:<dsc>:<c>:<prefercite>:<p>
#  :processing_information_head, # <ead>:<archdesc>:<dsc>:<c>:<processinfo>:<head>
#  :processing_information_values, # <ead>:<archdesc>:<dsc>:<c>:<processinfo>:<p>
  :physical_description_extents_string,
  :related_material_head, # <ead>:<archdesc>:<dsc>:<c>:<relatedmaterial>:<head>
  :related_material_values, # <ead>:<archdesc>:<dsc>:<c>:<related_material>:<p>
  :scope_and_content_head, # <ead>:<archdesc>:<dsc>:<c>:<scopecontent>:<head>
  :scope_and_content_values, # <ead>:<archdesc>:<dsc>:<c>:<scopecontent>:<p>
  :separated_material_head, # <ead>:<archdesc>:<dsc>:<c>:<separatedmaterial>:<head>
  :separated_material_values, # <ead>:<archdesc>:<dsc>:<c>:<separatedmaterial>:<p>
  :unit_dates, # <ead>:<archdesc>:<dsc>:<c>:<did>:<unitdate>
  :unit_title # <ead>:<archdesc>:<dsc>:<c>:<did>:<unittitle>
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
    #:lower_level_components_in_flattened_structure, # flattened structure containing enclosed lower level <c> elements

    context 'has ' do
      it '#parse method' do
        expect(subject).to respond_to(:parse).with(2).arguments
      end

      it '#generate_structure_containing_lower_level_components' do
        expect(subject).to respond_to(:generate_structure_containing_lower_level_components).with(2).arguments
      end

      it '#generate_children_components_info' do
        expect(subject).to respond_to(:generate_children_components_info).with(2).arguments
      end

      it '#generate_child_component_info' do
        expect(subject).to respond_to(:generate_child_component_info).with(2).arguments
      end
    end
  end

  ########################################## Functionality
  describe 'Testing functionality: ' do
    ########################################## generate_children_components_info
    describe 'generate_children_components_info' do
      before(:context) do
        xml_input = fixture_file_upload('ead/test_ead.xml').read
        nokogiri_xml_document = Nokogiri::XML(xml_input) do |config|
          config.norecover
        end
        component_xml_nokogiri_element =  nokogiri_xml_document.xpath('/xmlns:ead/xmlns:archdesc/xmlns:dsc/xmlns:c[@level="series"]').first
        @component_parser = ArchiveSpace::Parsers::ComponentParser.new
        # need to initialize @flattened_component_tree_structure by hand, normally initialized by
        # the generate_structure_containing_lower_level_components method, which is the method that
        # calls #generate_child_components_info
        @component_parser.instance_variable_set(:@flattened_component_tree_structure, [])
        @component_parser.generate_children_components_info(component_xml_nokogiri_element)
      end
      context 'given NOKOGIRI::XML::ELEMENT, representing a <c>, as an argument' do
        it 'the flattened_component_tree_structure is set correctly' do
          result = @component_parser.flattened_component_tree_structure
          expect(result[0][:unit_title]).to eq '<unittitle>Subseries 1: Cataloged Correspondence -- Letters</unittitle>'
          expect(result[0][:scope_and_content_values][1]).to eq '<p>The Builder. Nov 11, 1921. Excerpt;</p>'
          expect(result[0][:nesting_level]).to eq 1
          expect(result[1][:unit_title]).to eq '<unittitle>Herbert Brandon studio (Usonia, NY)</unittitle>'
          expect(result[1][:scope_and_content_values][0]).to eq '<p>In twenty boxes</p>'
          expect(result[1][:nesting_level]).to eq 2
        end
      end
    end

    ########################################## generate_child_component_info
    describe 'generate_child_component_info' do
      before(:context) do
        xml_input = fixture_file_upload('ead/test_ead.xml').read
        nokogiri_xml_document = Nokogiri::XML(xml_input) do |config|
          config.norecover
        end
        component_xml_nokogiri_element =  nokogiri_xml_document.xpath('/xmlns:ead/xmlns:archdesc/xmlns:dsc/xmlns:c[@level="series"]').first
        component_parser = ArchiveSpace::Parsers::ComponentParser.new
        @component_info = component_parser.generate_child_component_info(component_xml_nokogiri_element, 1)
        @expected_component_info = ArchiveSpace::Parsers::ComponentParser::ComponentInfo.new
        @expected_component_info.compound_title_string = 'Series I: Cataloged Correspondence, 1914-1989, 1894-1967, bulk 1958-1980'
        @expected_component_info.unit_dates = ['1914-1989', '1958-1980', '1894-1967']
        @expected_component_info.unit_title = '<unittitle>Series I: Cataloged Correspondence</unittitle>'
        @expected_component_info.acquisition_information_values = [
          '<p>Transferred from NYPL(ACQ)</p>',
          '<p>Transferred from CUL(ACQ)</p>',
          "<p>Transferred from Metro(ACQ)</p>"
        ]
        @expected_component_info.alternative_form_available_values = [
          '<p>Microforms available.(AF)</p>',
          '<p>Photocopies available.(AF)</p>',
          '<p>Microfiche available.(AF)</p>'
        ]
        @expected_component_info.arrangement_values = [
          '<p>Arranged alphabetically by subject.</p>',
          '<p>Arranged alphabetically by author.</p>',
          '<p>Arranged alphabetically by location.</p>'
        ]
        @expected_component_info.biography_or_history_values = [
          '<p>John ate pizza for lunch.(BH)</p>',
          '<p>John ate a burger for lunch.(BH)</p>',
          '<p>John ate fish for lunch.(BH)</p>'
        ]
        @expected_component_info.conditions_governing_access_values = [
          '<p>[Restricted Until 2039](top-level container)</p>',
          '<p>[Restricted Until 2059](top-level container)</p>',
          '<p>[Restricted Until 2020](top-level container)</p>'
        ]
        @expected_component_info.conditions_governing_use_values = [
          '<p>Five photocopies may be made for research purposes.(UR)</p>',
          '<p>One photocopy may be made for research purposes.(UR)</p>',
          '<p>Single photocopies may be made for research purposes.(UR)</p>'
        ]
        @expected_component_info.container_info_barcode =  'RS01729110'
        @expected_component_info.container_info_strings = [
          'Box 24',
          'General Manuscripts Box 78',
          'Folder 5'
        ]
        @expected_component_info.custodial_history_values = [
          '<p>Gift of the ABC Company, 1963.(CH)</p>',
          '<p>Gift of the BCD Company, 1963.(CH)</p>',
          '<p>Gift of the DDD Company, 1963.(CH)</p>'
        ]
        @expected_component_info.level_attribute = 'series'
        @expected_component_info.other_descriptive_data_values = [
          '<p>This collection is nice(ODD)</p>',
          '<p>This repo is nice(ODD)</p>',
          '<p>This series is nice(ODD)</p>'
        ]
        @expected_component_info.other_finding_aid_values = [
          '<p>*In addition, a sortable inventory in this downloadable Excel spreadsheet.</p>',
          '<p>A pdf version is available for download.</p>',
          '<p>Another finding aid available online.</p>'
        ]
        @expected_component_info.physical_description_extents_string =
          ["5 linear feet; 4 boxes 14 slipcases;",
           "7.6 Tb Digital; one hard disk;",
           "444 linear feet; 355 record cartons 15 document boxes and 4 flat boxes"
          ].join ' '
        @expected_component_info.related_material_values = [
          '<p>The related memoirs are cataloged individually(RM)</p>',
          '<p>The related photographs are cataloged individually(RM)</p>',
          '<p>The related recordings are cataloged individually(RM)</p>'
        ]
        @expected_component_info.scope_and_content_values = [
          '<p>The correspondence in the collection consist of letters and postcards.</p>',
          '<p>Correspondents include: James Joyce.</p>',
          '<p>Contains  document allowing Bunshaft to practice architecture in Belgium.</p>'
        ]
        @expected_component_info.separated_material_values = [
          "<p>Some interviewees' personal papers were separated and described as their own collection.</p>",
          '<p>Oral history transcripts in this series are drafts and editing copies.</p>',
          '<p>The personal papers and finalized individual memoirs are cataloged in CLIO.</p>'
        ]
      end

      context 'given NOKOGIRI::XML::ELEMENT, representing a <c>, as an argument' do
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

        it 'set the nesting_level member of ComponentInfo correctly' do
          expect(@component_info.nesting_level).to eq 1
        end

        it 'set the unit_dates members of ComponentInfo correctly' do
          unit_dates = @component_info.unit_dates
          expect(@expected_component_info.unit_dates.size).to eq unit_dates.size
          @expected_component_info.unit_dates.each_with_index do |expected_unit_date, index|
            expect(unit_dates[index].text).to eq expected_unit_date
          end
        end

        it 'sets the digital_archival_objects correctly' do
          digital_archival_objects = @component_info.digital_archival_objects
          expect(expected_digital_archival_objects.size).to eq digital_archival_objects.size
          expected_digital_archival_objects.each_with_index do |expected_digital_archival_object, index|
            expect(digital_archival_objects[index].href).to eq expected_digital_archival_object[:href]
            expect(digital_archival_objects[index].description).to eq expected_digital_archival_object[:description]
          end
        end
        test_members =
          ArchiveSpace::Parsers::ComponentParser::ComponentInfo.new.members  - [:digital_archival_objects, :nesting_level, :unit_dates]
        test_members.each do |member|
          it "sets the #{member} member of ComponentInfo correctly" do
            if "#{member}".ends_with? 'string'
              expect(@component_info[member]).to eq @expected_component_info[member]
            else
              expect(@component_info[member]).to eq @expected_component_info[member]
            end
          end
        end
      end
    end

    ########################################## parse
    describe 'parse' do
      before(:context) do
        xml_input = fixture_file_upload('ead/test_ead.xml').read
        nokogiri_xml_document = Nokogiri::XML(xml_input) do |config|
          config.norecover
        end
        @component_parser = ArchiveSpace::Parsers::ComponentParser.new
        @component_parser.parse(nokogiri_xml_document, 1)
      end

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

       let (:expected_compound_title_string) {
         'Series I: Cataloged Correspondence, 1914-1989, 1894-1967, bulk 1958-1980'
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

      let (:expected_container_info_strings) {
        [
          'Box 24',
          'General Manuscripts Box 78',
          'Folder 5'
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

       let (:expected_level_attribute) {
         'series'
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

      let (:expected_physical_description_extents_string) {
        ["5 linear feet; 4 boxes 14 slipcases;",
         "7.6 Tb Digital; one hard disk;",
         "444 linear feet; 355 record cartons 15 document boxes and 4 flat boxes"
        ].join ' '
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

      let (:expected_unit_dates) {
        [
          '1914-1989',
          '1958-1980',
          '1894-1967'
        ]
      }

      context 'given NOKOGIRI::XML::DOCUMENT as an argument' do
        it 'sets the compound_title_string attribute correctly' do
          expect(@component_parser.compound_title_string).to eq expected_compound_title_string
        end

        it 'sets the container_info_strings attribute correctly' do
          container_info_strings = @component_parser.container_info_strings
          expect(expected_container_info_strings.size).to eq container_info_strings.size
          expected_container_info_strings.each_with_index do |expected_info_string, index|
            expect(@component_parser.container_info_strings[index]).to eq expected_info_string
          end
        end

        it 'sets digital_archival_objects correctly' do
          digital_archival_objects = @component_parser.digital_archival_objects
          expect(expected_digital_archival_objects.size).to eq digital_archival_objects.size
          expected_digital_archival_objects.each_with_index do |expected_digital_archival_object, index|
            expect(digital_archival_objects[index].href).to eq expected_digital_archival_object[:href]
            expect(digital_archival_objects[index].description).to eq expected_digital_archival_object[:description]
          end
        end

        it 'sets the level_attribute attribute correctly' do
          expect(@component_parser.level_attribute).to eq expected_level_attribute
        end

        it 'sets the physical_description_extents_string attribute correctly' do
          expect(@component_parser.physical_description_extents_string).to eq expected_physical_description_extents_string
        end

        it 'sets the unit_dates attribute correctly' do
          expected_unit_dates.each_with_index do |expected_unit_date, index|
            expect(@component_parser.unit_dates[index].text).to eq expected_unit_date
          end
        end

        it 'sets the unit_title attribute correctly' do
          expect(@component_parser.unit_title.text).to eq 'Series I: Cataloged Correspondence'
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
end

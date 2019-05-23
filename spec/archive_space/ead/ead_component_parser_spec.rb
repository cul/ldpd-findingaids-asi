require 'rails_helper'
require 'archive_space/ead/ead_parser.rb'
require 'archive_space/ead/ead_component_parser.rb'

attributes = [
  :access_restrictions_ps, # <c>:<accessrestrict>:<p>
  :arrangement_ps, # <c>:<arrangement>:<p>
  :scope_content_ps, # <c>:<scopecontent>:<p>
  :separated_material_ps, # <c>:<sepratedmaterial>:<p>
  :other_finding_aid_ps, # <c>:<scopecontent>:<p>
  :title # <c>:<did>:<unititle>
].freeze

RSpec.describe ArchiveSpace::Ead::EadComponentParser do
  ########################################## API/interface
  describe 'API/interface' do
    context 'has attr_reader for instance var' do
      attributes.each do |attribute|
        it "#{attribute}" do
          expect(subject).to respond_to("#{attribute}")
        end
      end
    end

    context 'has' do
      it 'parse method that takes one argument' do
        expect(subject).to respond_to(:parse).with(1).argument
      end

      it 'generate_info method that takes no arguments' do
        expect(subject).to respond_to(:generate_info).with(0).arguments
      end

      it 'generate_child_components_info that takes one argument' do
        expect(subject).to respond_to(:generate_child_components_info).with(2).arguments
      end

      it 'generate_component_info that takes one argument' do
        expect(subject).to respond_to(:generate_component_info).with(1).arguments
      end
    end
  end

  ########################################## Functionality
  describe 'Testing functionality: ' do
    ########################################## parse
    context 'parse' do
      before(:example) do
        xml_input = fixture_file_upload('asi/test_c_element.xml').read
        @nokogiri_xml = Nokogiri::XML(xml_input)
        @as_ead_series = ArchiveSpace::Ead::EadComponentParser.new
        @as_ead_series.parse @nokogiri_xml.xpath('/xmlns:ead/xmlns:archdesc/xmlns:dsc/xmlns:c[@level="series"]')
      end

      let (:expected_access_restrictions_ps) {
        [
          "[Restricted Until 2039](top-level container)",
          "[Restricted Until 2059](top-level container)",
          "[Restricted Until 2020](top-level container)"
        ]
      }

      let (:expected_arrangement_ps) {
        [
          "Arranged alphabetically by subject.",
          "Arranged alphabetically by author.",
          "Arranged alphabetically by location."
        ]
      }

      let (:expected_other_finding_aid_ps) {
        [
          "*In addition, a sortable inventory in this downloadable Excel spreadsheet.",
          "A pdf version is available for download.",
          "Another finding aid available online."
        ]
      }

      let (:expected_scope_content_ps) {
        [
          "The drawings in the collection consist of pencil and ink drawings.",
          "Correspondents include: H.J. Heinz.",
          "Contains  document allowing Bunshaft to practice architecture in Belgium."
        ]
      }

      let (:expected_separated_material_ps) {
        [
          "Some interviewees' personal papers were separated and described as their own collection.",
          "Oral history transcripts in this series are drafts and editing copies.",
          "The personal papers and finalized individual memoirs are cataloged in CLIO."
        ]
      }

      it 'sets the access_restrictions_ps correctly' do
        @as_ead_series.access_restrictions_ps.each_with_index do |access_restrictions_p, index|
          expect(access_restrictions_p.text).to eq expected_access_restrictions_ps[index]
        end
      end

      it 'sets the arrangement_ps correctly' do
        @as_ead_series.arrangement_ps.each_with_index do |arrangement_p, index|
          expect(arrangement_p.text).to eq expected_arrangement_ps[index]
        end
      end

      it 'sets the other_finding_aid_ps correctly' do
        @as_ead_series.other_finding_aid_ps.each_with_index do |other_finding_aid_p, index|
          expect(other_finding_aid_p.text).to eq expected_other_finding_aid_ps[index]
        end
      end

      it 'sets the scope_content_ps correctly' do
        @as_ead_series.scope_content_ps.each_with_index do |scope_content_p, index|
          expect(scope_content_p.text).to eq expected_scope_content_ps[index]
        end
      end

      it 'sets the separated_material_ps correctly' do
        @as_ead_series.separated_material_ps.each_with_index do |separated_material_p, index|
          expect(separated_material_p.text).to eq expected_separated_material_ps[index]
        end
      end

      it 'sets the title correctly' do
        tested = @as_ead_series.title
        expect(tested).to eq 'Series I: Cataloged Correspondence'
      end
    end

    ########################################## generate_info
    context 'generate_info' do
      before(:example) do
        xml_input = fixture_file_upload('asi/test_c_element.xml').read
        @nokogiri_xml = Nokogiri::XML(xml_input)
        @as_ead_series = ArchiveSpace::Ead::EadComponentParser.new
        @as_ead_series.parse @nokogiri_xml.xpath('/xmlns:ead/xmlns:archdesc/xmlns:dsc/xmlns:c[@level="series"]')
        ( @nesting_level,
          @title,
          @physical_description,
          @date,
          @level,
          @container_info,
          @component_notes
        ) = @as_ead_series.generate_info.first
      end

      let (:expected_access_restrictions_ps) {
        [
          "<p>[Restricted Until 2049](child container)</p>",
          "<p>[Restricted Until 2047](child container)</p>",
          "<p>[Restricted Until 2059](child container)</p>"
        ]
      }

      let (:expected_arrangement_ps) {
        [
          "<p>Arranged alphabetically by topic.</p>",
          "<p>Arranged alphabetically by creator.</p>",
          "<p>Arranged alphabetically by repo.</p>"
        ]
      }

      let (:expected_scope_content_ps) {
        [
          "<p>In four boxes, numbered 1-4.</p>",
          "<p>The Builder. Nov 11, 1921. Excerpt;</p>",
          "<p>Notice de la constitution des societe local.</p>"
        ]
      }

      let (:expected_separated_material_ps) {
        [
          "<p>Some interviewees' personal papers were separated and described as their own collection.</p>",
          "<p>Oral history transcripts in this series are drafts and editing copies.</p>",
          "<p>The personal papers and finalized individual memoirs are cataloged in CLIO.</p>"
        ]
      }

      let (:expected_other_finding_aid_ps) {
        [
          "<p>*In addition, a sortable inventory in this downloadable Excel spreadsheet.</p>",
          "<p>A pdf version is available for download.</p>",
          "<p>Another finding aid available online.</p>"
        ]
      }

      it 'generates the correct nesting level' do
        expect(@nesting_level).to eq 1
      end

      it 'generates the correct title' do
        expect(@title).to eq 'Subseries I: Cataloged Correspondence'
      end

      it 'generates the correct physical description' do
        expect(@physical_description).to eq '(1 folder)'
      end

      it 'generates the correct level' do
        expect(@level).to eq 'series'
      end

      it 'generates the correct access_restrictions_ps values' do
        @component_notes.access_restrictions_ps.each_with_index do |access_restrictions_p, index|
          expect(access_restrictions_p).to eq expected_access_restrictions_ps[index]
        end
      end

      it 'generates the correct arrangement_ps values' do
        @component_notes.arrangement_ps.each_with_index do |arrangement_p, index|
          expect(arrangement_p).to eq expected_arrangement_ps[index]
        end
      end

      it 'generates the correct scope content values' do
        @component_notes.scope_content_ps.each_with_index do |scope_content_p, index|
          expect(scope_content_p).to eq expected_scope_content_ps[index]
        end
      end

      it 'generates the correct separated material values' do
        @component_notes.separated_material_ps.each_with_index do |separated_material_p, index|
          expect(separated_material_p).to eq expected_separated_material_ps[index]
        end
      end

      it 'generates the correct other finding aid values' do
        @component_notes.other_finding_aid_ps.each_with_index do |other_finding_aid_p, index|
          expect(other_finding_aid_p).to eq expected_other_finding_aid_ps[index]
        end
      end

      it 'generates the correct container info' do
        expect(@container_info).to eq ["General Manuscripts Box 78", "Folder 5"]
      end
    end
  end
end

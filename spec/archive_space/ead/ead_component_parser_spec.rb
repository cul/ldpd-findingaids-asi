require 'rails_helper'
require 'archive_space/ead/ead_parser.rb'
require 'archive_space/ead/ead_component_parser.rb'

attributes = [
  :title, # <c>:<did>:<unititle>
  :scope_content_value # <c>:<scopecontent>:<p>
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
    ########################################## generate_info
    context 'generate_info' do
      before(:example) do
        xml_input = fixture_file_upload('asi/test_c_element.xml').read
        @nokogiri_xml = Nokogiri::XML(xml_input)
        @as_ead_series = ArchiveSpace::Ead::EadComponentParser.new
        @as_ead_series.parse @nokogiri_xml.xpath('/xmlns:ead/xmlns:archdesc/xmlns:dsc/xmlns:c[@level="series"]')
        ( @nesting_level,
          @title,
          @date,
          @level,
          @scope_content_ps,
          @separated_material_ps,
          @other_finding_aid_values,
          @container_info ) = @as_ead_series.generate_info.first
      end

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

      let (:expected_other_finding_aid_values) {
        [
          "*In addition, a sortable inventory in this downloadable Excel spreadsheet.",
          "A pdf version is available for download.",
          "Another finding aid available online."
        ]
      }

      it 'generates the correct nesting level' do
        expect(@nesting_level).to eq 0
      end

      it 'generates the correct title' do
        expect(@title).to eq 'Series I: Cataloged Correspondence'
      end

      it 'generates the correct level' do
        expect(@level).to eq 'series'
      end

      it 'generates the correct scope content values' do
        @scope_content_ps.each_with_index do |scope_content_p, index|
          expect(scope_content_p).to eq expected_scope_content_ps[index]
        end
      end

      it 'generates the correct separated material values' do
        @separated_material_ps.each_with_index do |separated_material_p, index|
          expect(separated_material_p).to eq expected_separated_material_ps[index]
        end
      end

      it 'generates the correct other finding aid values' do
        @other_finding_aid_values.each_with_index do |other_finding_aid_value, index|
          expect(other_finding_aid_value.text).to eq expected_other_finding_aid_values[index]
        end
      end

      it 'generates the correct container info' do
        expect(@container_info).to eq ["Box 78", "Folder 5"]
      end
    end

    ########################################## parse
    context 'parse' do
      before(:example) do
        xml_input = fixture_file_upload('asi/test_c_element.xml').read
        @nokogiri_xml = Nokogiri::XML(xml_input)
        @as_ead_series = ArchiveSpace::Ead::EadComponentParser.new
        @as_ead_series.parse @nokogiri_xml.xpath('/xmlns:ead/xmlns:archdesc/xmlns:dsc/xmlns:c[@level="series"]')
      end

      it 'sets the title correctly' do
        tested = @as_ead_series.title
        expect(tested).to eq 'Series I: Cataloged Correspondence'
      end

      it 'sets the scope content correctly' do
        tested = @as_ead_series.scope_content_value
        expect(tested).to include "In four boxes, numbered 1-4."
      end
    end
  end
end

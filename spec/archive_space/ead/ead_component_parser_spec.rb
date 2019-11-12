require 'rails_helper'
require 'archive_space/ead/ead_parser.rb'
require 'archive_space/ead/ead_component_parser.rb'

attributes = [
  :access_restrictions_ps, # <c>:<accessrestrict>:<p>
  :acquisition_information_ps, # <c>:<acqinfo>:<p>
  :alternative_form_available_ps, # <c>:<altformavail>:<p>
  :arrangement_ps, # <c>:<arrangement>:<p>
  :biography_history_ps, # <c>:<bioghist>:<p>
  :custodial_history_ps, # <c>:<custodhist>:<p>
  :dates, # <c>:<did>:<unitdate>
  :odd_ps, # <c>:<odd>:<p>
  :other_finding_aid_ps, # <c>:<scopecontent>:<p>
  :related_material_ps, # <c>:<relatedmaterial>:<p>
  :scope_content_ps, # <c>:<scopecontent>:<p>
  :separated_material_ps, # <c>:<separatedmaterial>:<p>
  :title, # <c>:<did>:<unititle>
  :use_restrictions_ps # <c>:<userestrict>:<p>
].freeze

RSpec.describe ArchiveSpace::Ead::EadComponentParser do
  ########################################## API/interface
  describe 'API/interface' do
    context 'has attr_reader for instance var' do
      attributes.each do |attribute|
        it "#{attribute}" do
          expect(subject).to respond_to("#{attribute}")
        end

        it 'notes' do
          expect(subject).to respond_to('notes')
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
        @component = ArchiveSpace::Ead::EadComponentParser.new
        @component.parse @nokogiri_xml.xpath('/xmlns:ead/xmlns:archdesc/xmlns:dsc/xmlns:c[@level="series"]')
        @expected_access_restrictions_ps =
          [
            "[Restricted Until 2039](top-level container)",
            "[Restricted Until 2059](top-level container)",
            "[Restricted Until 2020](top-level container)"
          ]
        @expected_acquisition_information_ps =
          [
            "Transferred from NYPL(ACQ)",
            "Transferred from CUL(ACQ)",
            "Transferred from Metro(ACQ)"
          ]
        @expected_alternative_form_available_ps =
          [
            "Microforms available.(AF)",
            "Photocopies available.(AF)",
            "Microfiche available.(AF)"
          ]
        @expected_arrangement_ps =
          [
            "Arranged alphabetically by subject.",
            "Arranged alphabetically by author.",
            "Arranged alphabetically by location."
          ]
        @expected_biography_history_ps =
          [
            "John ate pizza for lunch.(BH)",
            "John ate a burger for lunch.(BH)",
            "John ate fish for lunch.(BH)"
          ]
        @expected_custodial_history_ps =
          [
            "Gift of the ABC Company, 1963.(CH)",
            "Gift of the BCD Company, 1963.(CH)",
            "Gift of the DDD Company, 1963.(CH)"
          ]
        @expected_digital_archival_object_description =
          [
            "Browse or Search Digital Materials",
            "Sub-subseries I.13.A: Secretariat Unrestricted Digital Files, 2001-2013"
          ]
        @expected_digital_archival_object_href =
          [
            "https://dlc.library.columbia.edu/ifp/partner/secretariat",
            "https://dlc.library.columbia.edu/ifp/partner/secretariat"
          ]
        @expected_odd_ps =
          [
            "This collection is nice(ODD)",
            "This repo is nice(ODD)",
            "This series is nice(ODD)"
          ]
        @expected_other_finding_aid_ps =
          [
            "*In addition, a sortable inventory in this downloadable Excel spreadsheet.",
            "A pdf version is available for download.",
            "Another finding aid available online."
          ]
        @expected_related_material_ps =
          [
            "The related memoirs are cataloged individually(RM)",
            "The related photographs are cataloged individually(RM)",
            "The related recordings are cataloged individually(RM)"
          ]
        @expected_scope_content_ps =
          [
            "The drawings in the collection consist of pencil and ink drawings.",
            "Correspondents include: H.J. Heinz.",
            "Contains  document allowing Bunshaft to practice architecture in Belgium."
          ]
        @expected_separated_material_ps =
          [
            "Some interviewees' personal papers were separated and described as their own collection.",
            "Oral history transcripts in this series are drafts and editing copies.",
            "The personal papers and finalized individual memoirs are cataloged in CLIO."
          ]
        @expected_use_restrictions_ps =
          [
            "Five photocopies may be made for research purposes.(UR)",
            "One photocopy may be made for research purposes.(UR)",
            "Single photocopies may be made for research purposes.(UR)"
          ]
      end

      (attributes - [:title, :digital_archival_object, :dates]).each do |key|
        it "sets the notes hash value for key #{key} correctly" do
          expected_values = instance_variable_get("@expected_#{key}")
          @component.notes[key].each_with_index do |value_p, index|
            expect(value_p.text).to eq expected_values[index]
          end
        end
      end

      it 'sets the digital archival objects href  correctly' do
        tested = @component.digital_archival_objects_description_href
        tested.each.with_index do |dao_info, index|
          expect(dao_info.first).to eq @expected_digital_archival_object_description[index]
          expect(dao_info.second).to eq @expected_digital_archival_object_href[index]
        end
      end

      it 'sets the title correctly' do
        tested = @component.title
        expect(tested).to eq 'Series I: Cataloged Correspondence'
      end
    end

    ########################################## generate_info
    context 'generate_info' do
      before(:example) do
        xml_input = fixture_file_upload('asi/test_c_element.xml').read
        @nokogiri_xml = Nokogiri::XML(xml_input)
        @component = ArchiveSpace::Ead::EadComponentParser.new
        @component.parse @nokogiri_xml.xpath('/xmlns:ead/xmlns:archdesc/xmlns:dsc/xmlns:c[@level="series"]')
        ( @nesting_level,
          @title,
          @physical_description,
          @dates,
          @digital_archival_objects_description_href,
          @level,
          @container_info,
          @component_notes
        ) = @component.generate_info.first
        @expected_access_restrictions_ps =
          [
            "<p>[Restricted Until 2049](child container)</p>",
            "<p>[Restricted Until 2047](child container)</p>",
            "<p>[Restricted Until 2059](child container)</p>"
          ]
        @expected_acquisition_information_ps =
          [
            "<p>Transferred from Avery(ACQ)</p>",
            "<p>Transferred from NYU(ACQ)</p>",
            "<p>Transferred from next door(ACQ)</p>"
          ]
        @expected_alternative_form_available_ps =
          [
            "<p>Film available.(AF)</p>",
            "<p>Hard copies available.(AF)</p>",
            "<p>Digital files available.(AF)</p>"
          ]
        @expected_arrangement_ps =
          [
            "<p>Arranged alphabetically by topic.</p>",
            "<p>Arranged alphabetically by creator.</p>",
            "<p>Arranged alphabetically by repo.</p>"
          ]
        @expected_biography_history_ps =
          [
            "<p>John ate pizza for dinner.(BH)</p>",
            "<p>John ate a burger for dinner.(BH)</p>",
            "<p>John ate fish for dinner.(BH)</p>"
          ]
        @expected_custodial_history_ps =
          [
            "<p>Gift of the ZZZ Company, 1963.(CH)</p>",
            "<p>Gift of the 123 Company, 1963.(CH)</p>",
            "<p>Gift of the Pi Company, 1963.(CH)</p>"
          ]
        @expected_digital_archival_object_description =
          [
            "Browse or Search Digital B Materials",
            "Sub-subseries I.13.B: Secretariat Unrestricted Digital Files, 2001-2013"
          ]
        @expected_digital_archival_object_href =
          [
            "https://dlc.library.columbia.edu/ifp/partner/secretariat",
            "https://dlc.library.columbia.edu/ifp/partner/secretariat"
          ]
        @expected_odd_ps =
          [
            "<p>This file is nice(ODD)</p>",
            "<p>This manuscript is nice(ODD)</p>",
            "<p>This picture is nice(ODD)</p>"
          ]
        @expected_other_finding_aid_ps =
          [
            "<p>*In addition, a sortable inventory in this downloadable Excel spreadsheet.</p>",
            "<p>A pdf version is available for download.</p>",
            "<p>Another finding aid available online.</p>"
          ]
        @expected_related_material_ps =
          [
            "<p>The related pictures are cataloged individually(RM)</p>",
            "<p>The related novels are cataloged individually(RM)</p>",
            "<p>The related slides are cataloged individually(RM)</p>"
          ]
        @expected_scope_content_ps =
          [
            "<p>In four boxes, numbered 1-4.</p>",
            "<p>The Builder. Nov 11, 1921. Excerpt;</p>",
            "<p>Notice de la constitution des societe local.</p>"
          ]
        @expected_separated_material_ps =
          [
            "<p>Some interviewees' personal papers were separated and described as their own collection.</p>",
            "<p>Oral history transcripts in this series are drafts and editing copies.</p>",
            "<p>The personal papers and finalized individual memoirs are cataloged in CLIO.</p>"
          ]
        @expected_use_restrictions_ps =
          [
            "<p>Four photocopies may be made for research purposes.(UR)</p>",
            "<p>Ten photocopies may be made for research purposes.(UR)</p>",
            "<p>Two photocopies may be made for research purposes.(UR)</p>"
          ]
      end

      (attributes - [:title, :dates]).each do |key|
        it "generates the correct notes hash value for key #{key}" do
          expected_values = instance_variable_get("@expected_#{key}")
          @component_notes[key].each_with_index do |value_p, index|
            expect(value_p).to eq expected_values[index]
          end
        end
      end

      it 'sets the digital archival objects href  correctly' do
        tested = @digital_archival_objects_description_href
        tested.each.with_index do |dao_info, index|
          expect(dao_info.first).to eq @expected_digital_archival_object_description[index]
          expect(dao_info.second).to eq @expected_digital_archival_object_href[index]
        end
      end

      it 'generates the correct nesting level' do
        expect(@nesting_level).to eq 1
      end

      it 'generates the correct title' do
        expect(@title).to eq '<unittitle>Subseries I: Cataloged Correspondence</unittitle>'
      end

      it 'generates the correct physical description' do
        expect(@physical_description).to eq '(1 folder)'
      end

      it 'generates the correct level' do
        expect(@level).to eq 'series'
      end

      it 'generates the correct container info' do
        expect(@container_info).to eq ["General Manuscripts Box 78", "Folder 5"]
      end
    end
  end
end

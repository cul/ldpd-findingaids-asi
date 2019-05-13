require 'rails_helper'
require 'archive_space/ead/ead_parser.rb'

attributes = [
  :archive_abstract, # <ead>:<archdesc>:<did>:<abstract>
  :archive_access_restrictions_head, # <ead>:<archdesc>:<accessrestrict>:<head>
  :archive_access_restrictions_values, # <ead>:<archdesc>:<accessrestrict>:<p>
  :archive_accruals_head, # <ead>:<archdesc>:<accruals>:<head>
  :archive_accruals_values, # <ead>:<archdesc>:<accruals>:<p>
  :archive_alternative_form_available_head, # <ead>:<archdesc>:<accruals>:<head>
  :archive_alternative_form_available_values, # <ead>:<archdesc>:<accruals>:<p>
  :archive_biography_history_head, # <ead>:<archdesc>:<bioghist>:<head>
  :archive_biography_history_values, # <ead>:<archdesc>:<bioghist>:<p>
  :archive_date, # <ead>:<archdesc>:<did>:<unitdate>
  :archive_dsc_series, # <ead>:<archdesc>:<dsc>:<c level=series>, returns array of series
  :archive_dsc_series_titles, # <ead>:<archdesc>:<dsc>:<c level=series><did><unittitle>, returns array of titles
  :archive_id, # <ead>:<archdesc>:<did>:<unitid>
  :archive_language, # <ead>:<archdesc>:<did>:<langmaterial><language>
  :archive_origination_creator, # <ead>:<archdesc>:<did>:<origination label="creator">
  :archive_physical_description_extent_carrier, # <ead>:<archdesc>:<did>:<physdesc>:<extent @altrender="carrier">
  :archive_preferred_citation_head, # <ead>:<archdesc>:<prefercite>:<head>
  :archive_preferred_citation_values, # <ead>:<archdesc>:<prefercite>:<p>
  :archive_processing_information_head, # <ead>:<archdesc>:<processinfo>:<head>
  :archive_processing_information_values, # <ead>:<archdesc>:<processinfo>:<p>
  :archive_related_material_head, # <ead>:<archdesc>:<relatedmaterial>:<head>
  :archive_related_material_values, # <ead>:<archdesc>:<related_material>:<p>
  :archive_repository, # <ead><archdesc><did><repository><corpname>
  :archive_revision_description_changes, # <ead><archheader><revisiondesc><change>
  :archive_scope_content_head, # <ead>:<archdesc>:<scopecontent>:<head>
  :archive_scope_content_values, # <ead>:<archdesc>:<scopecontent>:<p>
  :archive_title, # <ead>:<archdesc>:<did>:<unititle>
  :archive_use_restrictions_head, # <ead>:<archdesc>:<userestrict>:<head>
  :archive_use_restrictions_values # <ead>:<archdesc>:<userestrict>:<p>
].freeze


RSpec.describe ArchiveSpace::Ead::EadParser do
  ########################################## API/interface
  describe 'API/interface' do
    before(:context) do
      xml_input = fixture_file_upload('asi/as_ead_resource_4767_representation.xml').read
      @as_ead = ArchiveSpace::Ead::EadParser.new xml_input
    end

    context 'has attr_reader for instance var' do
      attributes.each do |attribute|
        it "#{attribute}" do
          expect(@as_ead).to respond_to("#{attribute}")
        end
      end
    end

    context 'has ' do
      it 'has #parse_ead_header method' do
        expect(@as_ead).to respond_to(:parse_ead_header).with(1).arguments
      end

      it 'has #parse_arch_desc_did method' do
        expect(@as_ead).to respond_to(:parse_arch_desc_did).with(1).arguments
      end

      it 'has #parse_arch_desc_dsc method' do
        expect(@as_ead).to respond_to(:parse_arch_desc_dsc).with(1).arguments
      end

      it 'has #parse_arch_desc_misc method' do
        expect(@as_ead).to respond_to(:parse_arch_desc_misc).with(1).arguments
      end
    end
  end

  ########################################## Functionality
  describe 'Testing functionality (NEW): ' do
    before(:context) do
      xml_input = fixture_file_upload('asi/test_as_ead_resource.xml').read
      @as_ead = ArchiveSpace::Ead::EadParser.new xml_input
      nokogiri_xml = Nokogiri::XML(xml_input)
      # @as_ead.parse_arch_desc_dsc nokogiri_xml
    end

    ########################################## parse_arch_desc_misc
    context 'parse_ead_header' do
      let (:expected_revision_change_dates) {
        [
          "2009-06-26",
          "2019-04-01"
        ]
      }

      let (:expected_revision_change_items) {
        [
          "File created.",
          "EAD was imported during the ArchivesSpace Phase II migration."
        ]
      }

      it 'parses the archive_revision_description_changes correctly' do
        @as_ead.archive_revision_description_changes.each_with_index do |change, index|
          expect(change[:date]).to eq expected_revision_change_dates[index]
          expect(change[:item]).to eq expected_revision_change_items[index]
        end
      end
    end

    ########################################## parse_arch_desc_did
    context 'parse_arch_desc_did' do
      it 'parses the archive_abstract correctly' do
        tested = @as_ead.archive_abstract
        expect(tested).to eq "This collection is made up of architectural drawings."
      end

      it 'parses the archive_date correctly' do
        tested = @as_ead.archive_date
        expect(tested).to eq "1894-1966"
      end

      it 'parses the archive_id correctly' do
        tested = @as_ead.archive_id
        expect(tested).to eq '4079591'
      end

      it 'parses the archive_language correctly' do
        tested = @as_ead.archive_language
        expect(tested).to eq 'Material is in English and in French, with some materials in Dutch.'
      end

      # TODO: need to verify how the sibling <extent> elements are parsed
      it 'parses the archive_physical_description_extent_carrier correctly' do
        tested = @as_ead.archive_physical_description_extent_carrier
        expect(tested).to eq '4 boxes 13 slipcases'
        # expect(tested).to eq '3 linear feet 4 boxes 13 slipcases'
      end

      it 'parses the archive_repository correctly' do
        tested = @as_ead.archive_repository
        expect(tested).to eq 'Rare Book and Manuscript Library'
      end

      it 'parses the archive_title correctly' do
        tested = @as_ead.archive_title
        expect(tested).to eq 'Siegfried Sassoon papers'
      end
    end

    ########################################## parse_arch_desc_dsc
    xcontext 'parse_arch_desc_dsc' do
      it 'parses the archive_dsc_series correctly' do
        tested = @as_ead.archive_dsc_series[0]
        expect(tested).to be_instance_of Nokogiri::XML::Element
      end

      it 'parses the archive_dsc_series_titles correctly' do
        tested = @as_ead.archive_dsc_series_titles
        expect(tested).to include 'Series VII: Bookplates'
      end
    end

    ########################################## parse_arch_desc_misc
    context 'parse_arch_desc_misc' do
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

      let (:expected_alternative_form_available_values) {
        [
          "Selected manuscripts are on: microfilm.",
          "Selected manuscripts are on: microfiche."
        ]
      }

      let (:expected_biography_history_values) {
        [
          "Siegfried Loraine Sassoon, CBE, MC was an English poet, writer, and soldier.",
          "Decorated for bravery on the Western Front."
        ]
      }

      let (:expected_preferred_citation_values) {
        [
          "Identification of specific item.",
          "Date and Provenance of specific item."
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

      let (:expected_scope_content_values) {
        [
          "The Edith Elmer Wood Collection covers a short but important period in the housing field.",
          "The collection documents this period."
        ]
      }

      let (:expected_use_restrictions_values) {
        [
          "Readers must use microfilm of materials specified above.",
          "Single photocopies may be made for research purposes."
        ]
      }

      it 'parses the archive_access_restrictions_head correctly' do
        tested = @as_ead.archive_access_restrictions_head
        expect(tested).to eq 'Restrictions on Access'
      end

      it 'parses the archive_access_restrictions_values correctly' do
        @as_ead.archive_access_restrictions_values.each_with_index do |access_restrictions_value, index|
          expect(access_restrictions_value.text).to eq expected_access_restrictions_values[index]
        end
      end

      it 'parses the archive_accruals_head correctly' do
        tested = @as_ead.archive_accruals_head
        expect(tested).to eq 'Accruals'
      end

      it 'parses the archive_accruals_values correctly' do
        @as_ead.archive_accruals_values.each_with_index do |accruals_value, index|
          expect(accruals_value.text).to eq expected_accruals_values[index]
        end
      end

      it 'parses the archive_alternative_form_available_head correctly' do
        tested = @as_ead.archive_alternative_form_available_head
        expect(tested).to eq 'Alternate Form Available'
      end

      it 'parses the archive_alternative_form_available_values correctly' do
        @as_ead.archive_alternative_form_available_values.each_with_index do |alternative_form_available_value, index|
          expect(alternative_form_available_value.text).to eq expected_alternative_form_available_values[index]
        end
      end

      it 'parses the archive_biography_history_head correctly' do
        tested = @as_ead.archive_biography_history_head
        expect(tested).to eq 'Biographical note'
      end

      it 'parses the archive_biography_history_values correctly' do
        @as_ead.archive_biography_history_values.each_with_index do |biography_history_value, index|
          expect(biography_history_value.text).to eq expected_biography_history_values[index]
        end
      end

      it 'parses the archive_preferred_citation_head correctly' do
        tested = @as_ead.archive_preferred_citation_head
        expect(tested).to eq 'Preferred Citation'
      end

      it 'parses the archive_preferred_citation_values correctly' do
        @as_ead.archive_preferred_citation_values.each_with_index do |preferred_citation_value, index|
          expect(preferred_citation_value.text).to eq expected_preferred_citation_values[index]
        end
      end

      it 'parses the archive_processing_information_head correctly' do
        tested = @as_ead.archive_processing_information_head
        expect(tested).to eq 'Processing Information'
      end

      it 'parses the archive_processing_information_values correctly' do
        @as_ead.archive_processing_information_values.each_with_index do |processing_information_value, index|
          expect(processing_information_value.text).to eq expected_processing_information_values[index]
        end
      end

      it 'parses the archive_related_material_head correctly' do
        tested = @as_ead.archive_related_material_head
        expect(tested).to eq 'Related Materials'
      end

      it 'parses the archive_related_material_values correctly' do
        @as_ead.archive_related_material_values.each_with_index do |related_material_value, index|
          expect(related_material_value.text).to eq expected_related_material_values[index]
        end
      end

      it 'parses the archive_scope_content_head correctly' do
        tested = @as_ead.archive_scope_content_head
        expect(tested).to eq 'Scope and Content'
      end

      it 'parses the archive_scope_content_values correctly' do
        @as_ead.archive_scope_content_values.each_with_index do |scope_content_value, index|
          expect(scope_content_value.text).to eq expected_scope_content_values[index]
        end
      end

      it 'parses the archive_use_restrictions_head correctly' do
        tested = @as_ead.archive_use_restrictions_head
        expect(tested).to eq 'Terms Governing Use and Reproduction'
      end

      it 'parses the archive_use_restrictions_values correctly' do
        @as_ead.archive_use_restrictions_values.each_with_index do |use_restrictions_value, index|
          expect(use_restrictions_value.text).to eq expected_use_restrictions_values[index]
        end
      end
    end
  end

  context "API/interface" do
    xit 'has #get_series_scope_content' do
      expect(subject).to respond_to(:get_series_scope_content).with(0).arguments
    end

    xit 'has #get_subjects' do
      expect(subject).to respond_to(:get_subjects).with(0).arguments
    end

    xit 'has #get_genres_forms' do
      expect(subject).to respond_to(:get_genres_forms).with(0).arguments
    end

    xit 'has #get_files_info_for_series' do
      expect(subject).to respond_to(:get_files_info_for_series).with(1).arguments
    end
  end

  describe 'Processing' do
    before(:context) do
      xml_input = fixture_file_upload('asi/as_ead_resource_4767_representation.xml').read
      @as_ead_nokogiri_xml = ArchiveSpace::Ead::EadParser.new xml_input
    end

    context "check functionality" do
      xit 'get_subjects returns correct value' do
        tested = @as_ead_nokogiri_xml.get_subjects
        expect(tested).to include 'Graphic arts'
      end

      xit 'get_genres_forms returns correct value' do
        tested = @as_ead_nokogiri_xml.get_genres_forms
        expect(tested).to include 'Lithographs'
      end

      xit 'get_files_info_for_series' do
        tested = @as_ead_nokogiri_xml.get_files_info_for_series 2
        expect(tested).to include({:title=>"Gag, Wanda Hazel.  [Spinning wheel], lithograph, (10.75\" x 9\")", :box_number=> "13V-F-01"})
      end
    end
  end
end

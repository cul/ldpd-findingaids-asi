require 'rails_helper'
require 'archive_space/ead/ead_parser.rb'

attributes = [
  :abstract, # <ead>:<archdesc>:<did>:<abstract>
  :access_restrictions_head, # <ead>:<archdesc>:<accessrestrict>:<head>
  :access_restrictions_values, # <ead>:<archdesc>:<accessrestrict>:<p>
  :accruals_head, # <ead>:<archdesc>:<accruals>:<head>
  :accruals_values, # <ead>:<archdesc>:<accruals>:<p>
  :alternative_form_available_head, # <ead>:<archdesc>:<accruals>:<head>
  :alternative_form_available_values, # <ead>:<archdesc>:<accruals>:<p>
  :biography_history_head, # <ead>:<archdesc>:<bioghist>:<head>
  :biography_history_values, # <ead>:<archdesc>:<bioghist>:<p>
  :control_access_corpnames, # <ead>:<archdesc>:<controlaccess>:<corpname>
  :control_access_genres_forms, # <ead>:<archdesc>:<controlaccess>:<genreform>
  :control_access_occupations, # <ead>:<archdesc>:<controlaccess>:<occupation>
  :control_access_persnames, # <ead>:<archdesc>:<controlaccess>:<persname>
  :control_access_subjects, # <ead>:<archdesc>:<controlaccess>:<subject>
  :date, # <ead>:<archdesc>:<did>:<unitdate>
  :dsc_series, # <ead>:<archdesc>:<dsc>:<c level=series>, returns array of series
  :dsc_series_titles, # <ead>:<archdesc>:<dsc>:<c level=series><did><unittitle>, returns array of titles
  :id, # <ead>:<archdesc>:<did>:<unitid>
  :language, # <ead>:<archdesc>:<did>:<langmaterial><language>
  :odd_head, # <ead>:<archdesc>:<odd>:<head>
  :odd_values, # <ead>:<archdesc>:<odd>:<p>
  :origination_creators, # <ead>:<archdesc>:<did>:<origination label="creator">
  :physical_description_extent_carrier, # <ead>:<archdesc>:<did>:<physdesc>:<extent @altrender="carrier">
  :preferred_citation_head, # <ead>:<archdesc>:<prefercite>:<head>
  :preferred_citation_values, # <ead>:<archdesc>:<prefercite>:<p>
  :processing_information_head, # <ead>:<archdesc>:<processinfo>:<head>
  :processing_information_values, # <ead>:<archdesc>:<processinfo>:<p>
  :related_material_head, # <ead>:<archdesc>:<relatedmaterial>:<head>
  :related_material_values, # <ead>:<archdesc>:<related_material>:<p>
  :repository, # <ead><archdesc><did><repository><corpname>
  :revision_description_changes, # <ead><archheader><revisiondesc><change>
  :scope_content_head, # <ead>:<archdesc>:<scopecontent>:<head>
  :scope_content_values, # <ead>:<archdesc>:<scopecontent>:<p>
  :separated_material_head, # <ead>:<archdesc>:<separatedmaterial>:<head>
  :separated_material_values, # <ead>:<archdesc>:<separatedmaterial>:<p>
  :unit_title, # <ead>:<archdesc>:<did>:<unititle>
  :use_restrictions_head, # <ead>:<archdesc>:<userestrict>:<head>
  :use_restrictions_values # <ead>:<archdesc>:<userestrict>:<p>
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

      it 'parses the revision_description_changes correctly' do
        @as_ead.revision_description_changes.each_with_index do |change, index|
          expect(change[:date]).to eq expected_revision_change_dates[index]
          expect(change[:item]).to eq expected_revision_change_items[index]
        end
      end
    end

    ########################################## parse_arch_desc_did
    context 'parse_arch_desc_did' do
      let (:expected_origination_creators) {
        [
          "Smith, John",
          "Sassoon, Siegfried, 1886-1967"
        ]
      }

      it 'parses the abstract correctly' do
        tested = @as_ead.abstract
        expect(tested).to eq "This collection is made up of architectural drawings."
      end

      it 'parses the date correctly' do
        tested = @as_ead.date
        expect(tested).to eq "1894-1966"
      end

      it 'parses the id correctly' do
        tested = @as_ead.id
        expect(tested).to eq '4079591'
      end

      it 'parses the language correctly' do
        tested = @as_ead.language
        expect(tested).to eq 'Material is in English and in French, with some materials in Dutch.'
      end

      it 'parses the originations_creators correctly' do
        @as_ead.origination_creators.each_with_index do |creator, index|
          expect(creator.text).to eq expected_origination_creators[index]
        end
      end

      # TODO: need to verify how the sibling <extent> elements are parsed
      it 'parses the physical_description_extent_carrier correctly' do
        tested = @as_ead.physical_description_extent_carrier
        expect(tested).to eq '4 boxes 13 slipcases'
        # expect(tested).to eq '3 linear feet 4 boxes 13 slipcases'
      end

      it 'parses the repository correctly' do
        tested = @as_ead.repository
        expect(tested).to eq 'Rare Book and Manuscript Library'
      end

      it 'parses the unit_title correctly' do
        tested = @as_ead.unit_title
        expect(tested).to eq 'Siegfried Sassoon papers'
      end
    end

    ########################################## parse_arch_desc_dsc
    xcontext 'parse_arch_desc_dsc' do
      it 'parses the dsc_series correctly' do
        tested = @as_ead.dsc_series[0]
        expect(tested).to be_instance_of Nokogiri::XML::Element
      end

      it 'parses the dsc_series_titles correctly' do
        tested = @as_ead.dsc_series_titles
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

      let (:expected_control_access_corpnames) {
        [
          "Barnard College",
          "Simon and Schuster, Inc"
        ]
      }

      let (:expected_control_access_genres_forms) {
        [
          "Illustrations",
          "Initials"
        ]
      }

      let (:expected_control_access_occupations) {
        [
          "Artists",
          "Cartoonists"
        ]
      }

      let (:expected_control_access_persnames) {
        [
          "Fritz, Chester",
          "Tong, Te-kong, 1920-2009"
        ]
      }

      let (:expected_control_access_subjects) {
        [
          "Art",
          "Drawing"
        ]
      }

      let (:expected_preferred_citation_values) {
        [
          "Identification of specific item.",
          "Date and Provenance of specific item."
        ]
      }

      let (:expected_odd_values) {
        [
          "Other collections of Rockwell Kent materials are at: SUNY-Plattsburgh (Rockwell Kent Collection).",
          "This is the collection-level record for which 700 associated project-level records were created."
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

      let (:expected_separated_material_values) {
        [
          "Interviewees' personal papers were separated.",
          "Researchers may find the personal papers on CLIO."
        ]
      }

      let (:expected_use_restrictions_values) {
        [
          "Readers must use microfilm of materials specified above.",
          "Single photocopies may be made for research purposes."
        ]
      }

      it 'parses the access_restrictions_head correctly' do
        tested = @as_ead.access_restrictions_head
        expect(tested).to eq 'Restrictions on Access'
      end

      it 'parses the access_restrictions_values correctly' do
        @as_ead.access_restrictions_values.each_with_index do |access_restrictions_value, index|
          expect(access_restrictions_value.text).to eq expected_access_restrictions_values[index]
        end
      end

      it 'parses the accruals_head correctly' do
        tested = @as_ead.accruals_head
        expect(tested).to eq 'Accruals'
      end

      it 'parses the accruals_values correctly' do
        @as_ead.accruals_values.each_with_index do |accruals_value, index|
          expect(accruals_value.text).to eq expected_accruals_values[index]
        end
      end

      it 'parses the alternative_form_available_head correctly' do
        tested = @as_ead.alternative_form_available_head
        expect(tested).to eq 'Alternate Form Available'
      end

      it 'parses the alternative_form_available_values correctly' do
        @as_ead.alternative_form_available_values.each_with_index do |alternative_form_available_value, index|
          expect(alternative_form_available_value.text).to eq expected_alternative_form_available_values[index]
        end
      end

      it 'parses the biography_history_head correctly' do
        tested = @as_ead.biography_history_head
        expect(tested).to eq 'Biographical note'
      end

      it 'parses the biography_history_values correctly' do
        @as_ead.biography_history_values.each_with_index do |biography_history_value, index|
          expect(biography_history_value.text).to eq expected_biography_history_values[index]
        end
      end

      it 'parses the control_access_corpnames correctly' do
        tested = @as_ead.control_access_corpnames
        expect(tested).to eq expected_control_access_corpnames
      end

      it 'parses the control_access_genres_forms correctly' do
        tested = @as_ead.control_access_genres_forms
        expect(tested).to eq expected_control_access_genres_forms
      end
      it 'parses the control_access_occupations correctly' do
        tested = @as_ead.control_access_occupations
        expect(tested).to eq expected_control_access_occupations
      end
      it 'parses the control_access_persnames correctly' do
        tested = @as_ead.control_access_persnames
        expect(tested).to eq expected_control_access_persnames
      end
      it 'parses the control_access_subjects correctly' do
        tested = @as_ead.control_access_subjects
        expect(tested).to eq expected_control_access_subjects
      end

      it 'parses the odd_head correctly' do
        tested = @as_ead.odd_head
        expect(tested).to eq 'General Note'
      end

      it 'parses the odd_values correctly' do
        @as_ead.odd_values.each_with_index do |odd_value, index|
          expect(odd_value.text).to eq expected_odd_values[index]
        end
      end

      it 'parses the preferred_citation_head correctly' do
        tested = @as_ead.preferred_citation_head
        expect(tested).to eq 'Preferred Citation'
      end

      it 'parses the preferred_citation_values correctly' do
        @as_ead.preferred_citation_values.each_with_index do |preferred_citation_value, index|
          expect(preferred_citation_value.text).to eq expected_preferred_citation_values[index]
        end
      end

      it 'parses the processing_information_head correctly' do
        tested = @as_ead.processing_information_head
        expect(tested).to eq 'Processing Information'
      end

      it 'parses the processing_information_values correctly' do
        @as_ead.processing_information_values.each_with_index do |processing_information_value, index|
          expect(processing_information_value.text).to eq expected_processing_information_values[index]
        end
      end

      it 'parses the related_material_head correctly' do
        tested = @as_ead.related_material_head
        expect(tested).to eq 'Related Materials'
      end

      it 'parses the related_material_values correctly' do
        @as_ead.related_material_values.each_with_index do |related_material_value, index|
          expect(related_material_value.text).to eq expected_related_material_values[index]
        end
      end

      it 'parses the scope_content_head correctly' do
        tested = @as_ead.scope_content_head
        expect(tested).to eq 'Scope and Content'
      end

      it 'parses the scope_content_values correctly' do
        @as_ead.scope_content_values.each_with_index do |scope_content_value, index|
          expect(scope_content_value.text).to eq expected_scope_content_values[index]
        end
      end

      it 'parses the separated_material_head correctly' do
        tested = @as_ead.separated_material_head
        expect(tested).to eq 'Separated Materials'
      end

      it 'parses the separated_material_values correctly' do
        @as_ead.separated_material_values.each_with_index do |separated_material_value, index|
          expect(separated_material_value.text).to eq expected_separated_material_values[index]
        end
      end

      it 'parses the use_restrictions_head correctly' do
        tested = @as_ead.use_restrictions_head
        expect(tested).to eq 'Terms Governing Use and Reproduction'
      end

      it 'parses the use_restrictions_values correctly' do
        @as_ead.use_restrictions_values.each_with_index do |use_restrictions_value, index|
          expect(use_restrictions_value.text).to eq expected_use_restrictions_values[index]
        end
      end
    end
  end

  context "API/interface" do
    xit 'has #get_series_scope_content' do
      expect(subject).to respond_to(:get_series_scope_content).with(0).arguments
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
      xit 'get_files_info_for_series' do
        tested = @as_ead_nokogiri_xml.get_files_info_for_series 2
        expect(tested).to include({:title=>"Gag, Wanda Hazel.  [Spinning wheel], lithograph, (10.75\" x 9\")", :box_number=> "13V-F-01"})
      end
    end
  end
end

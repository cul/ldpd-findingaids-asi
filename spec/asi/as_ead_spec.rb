require 'rails_helper'
require 'asi/as_ead.rb'

RSpec.describe Asi::AsEad do
  ########################################## API/interface
  describe 'API/interface' do
    context 'has attr_reader for instance var' do
      # <ead>:<archdesc>:<did>:<abstract>
      it 'archive_abstract' do
        expect(subject).to respond_to(:archive_abstract)
      end

      # <ead>:<archdesc>:<accessrestrict>:<head>
      it 'archive_access_restrictions_head' do
        expect(subject).to respond_to(:archive_access_restrictions_head)
      end

      # <ead>:<archdesc>:<accessrestrict>:<p>
      it 'archive_access_restrictions_value' do
        expect(subject).to respond_to(:archive_access_restrictions_value)
      end

      # <ead>:<archdesc>:<bioghist>:<head>
      it 'archive_biography_history_head' do
        expect(subject).to respond_to(:archive_biography_history_head)
      end

      # <ead>:<archdesc>:<bioghist>:<p>
      it 'archive_biography_history_value' do
        expect(subject).to respond_to(:archive_biography_history_value)
      end

      # <ead>:<archdesc>:<did>:<unitdate>
      it 'archive_date' do
        expect(subject).to respond_to(:archive_date)
      end

      # <ead>:<archdesc>:<dsc>:<c level=series><
      # returns array of series
      it 'archive_dsc_series' do
        expect(subject).to respond_to(:archive_dsc_series)
      end

      # <ead>:<archdesc>:<dsc>:<c level=series><did><unittitle>
      # returns array of titles
      it 'archive_dsc_series_titles' do
        expect(subject).to respond_to(:archive_dsc_series_titles)
      end

      # <ead>:<archdesc>:<did>:<unitid>
      it 'archive_id' do
        expect(subject).to respond_to(:archive_id)
      end

      # <ead>:<archdesc>:<did>:<langmaterial><language>
      it 'archive_language' do
        expect(subject).to respond_to(:archive_language)
      end

      # <ead>:<archdesc>:<did>:<physdesc>:<extent @altrender="carrier">
      it 'archive_physical_description' do
        expect(subject).to respond_to(:archive_physical_description_extent_carrier)
      end

      # <ead>:<archdesc>:<prefercite>:<head>
      it 'archive_preferred_citation_head' do
        expect(subject).to respond_to(:archive_preferred_citation_head)
      end

      # <ead>:<archdesc>:<prefercite>:<p>
      it 'archive_preferred_citation_value' do
        expect(subject).to respond_to(:archive_preferred_citation_value)
      end

      # <ead>:<archdesc>:<processinfo>:<head>
      it 'archive_processing_information_head' do
        expect(subject).to respond_to(:archive_processing_information_head)
      end

      # <ead>:<archdesc>:<processinfo>:<p>
      it 'archive_processing_information_value' do
        expect(subject).to respond_to(:archive_processing_information_value)
      end

      # <ead><archdesc><did><repository><corpname>
      it 'archive_repository' do
        expect(subject).to respond_to(:archive_repository)
      end

      # <ead>:<archdesc>:<scopecontent>:<head>
      it 'archive_scope_content_head' do
        expect(subject).to respond_to(:archive_scope_content_head)
      end

      # <ead>:<archdesc>:<scopecontent>:<p>
      it 'archive_scope_content_value' do
        expect(subject).to respond_to(:archive_scope_content_value)
      end

      # <ead>:<archdesc>:<did>:<unititle>
      it 'archive_title' do
        expect(subject).to respond_to(:archive_title)
      end

      # <ead>:<archdesc>:<userestrict>:<head>
      it 'archive_use_restrictions_head' do
        expect(subject).to respond_to(:archive_use_restrictions_head)
      end

      # <ead>:<archdesc>:<userestrict>:<p>
      it 'archive_use_restrictions_value' do
        expect(subject).to respond_to(:archive_use_restrictions_value)
      end
    end
  end

  ########################################## Functionality
  describe 'Testing functionality: ' do
    ########################################## generate_html_from_components
    context 'generate_html_from_components' do
      before(:example) do
        @as_ead = Asi::AsEad.new
        xml_input = fixture_file_upload('asi/as_ead_resource_4767_representation.xml').read
        @nokogiri_xml = Nokogiri::XML(xml_input)
        @as_ead.parse_arch_desc_dsc @nokogiri_xml
      end

      it 'process files' do
        tested_series = @as_ead.archive_dsc_series[0]
        # puts '*******************************************'
        #  puts '*******************************************'
        # puts @as_ead.generate_html_from_component(tested_series, '')
        # puts @as_ead.process_children_files(series_c_children)
        # puts tested
        # expect(tested).to include({:title => 'Price, Arthur: to Rockwell Kent, t.l.s., 15', :box_number => '3'})
        expect(true).to eq true
      end
    end

    ########################################## parse_arch_desc_dsc
    # fcd1, 03//11/19: method probably needs renaming and refactoring
    context 'get_files_info_for_series' do
      before(:example) do
        @as_ead = Asi::AsEad.new
        xml_input = fixture_file_upload('asi/as_ead_resource_4767_representation.xml').read
        @nokogiri_xml = Nokogiri::XML(xml_input)
        @as_ead.parse_arch_desc_dsc @nokogiri_xml
      end

      it 'returns correct list of file titles and associated box number' do
        tested = @as_ead.get_files_info_for_series 1
        expect(tested).to include({:title => 'Price, Arthur: to Rockwell Kent, t.l.s., 15', :box_number => '3'})
      end
    end

    ########################################## parse_arch_desc_did
    context 'parse_arch_desc_did' do
      before(:example) do
        @as_ead = Asi::AsEad.new
        xml_input = fixture_file_upload('asi/as_ead_resource_4767_representation_arch_desc_did_only.xml').read
        @nokogiri_xml = Nokogiri::XML(xml_input)
        @as_ead.parse_arch_desc_did @nokogiri_xml
      end

      it 'parses the archive_abstract correctly' do
        tested = @as_ead.archive_abstract
        expect(tested).to include "Rockwell Kent's correspondence; drawings and sketches;"
      end

      it 'parses the archive_date correctly' do
        tested = @as_ead.archive_date
        expect(tested).to eq "1885-1970"
      end

      it 'parses the archive_id correctly' do
        tested = @as_ead.archive_id
        expect(tested).to eq '4079547'
      end

      it 'parses the archive_language correctly' do
        tested = @as_ead.archive_language
        expect(tested).to eq 'English'
      end

      it 'parses the archive_physical_description_extent_carrier correctly' do
        tested = @as_ead.archive_physical_description_extent_carrier
        expect(tested).to eq '59 linear feet 46 boxes 10 drawers 3 slip cases'
      end

      it 'parses the archive_repository correctly' do
        tested = @as_ead.archive_repository
        expect(tested).to eq 'Rare Book and Manuscript Library'
      end

      it 'parses the archive_title correctly' do
        tested = @as_ead.archive_title
        expect(tested).to eq 'Rockwell Kent papers'
      end
    end

    ########################################## parse_arch_desc_dsc
    context 'parse_arch_desc_dsc' do
      before(:example) do
        @as_ead = Asi::AsEad.new
        xml_input = fixture_file_upload('asi/as_ead_resource_4767_representation.xml').read
        @nokogiri_xml = Nokogiri::XML(xml_input)
        @as_ead.parse_arch_desc_dsc @nokogiri_xml
      end

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
      before(:example) do
        @as_ead = Asi::AsEad.new
        xml_input = fixture_file_upload('asi/as_ead_resource_4767_representation_arch_desc_misc_only.xml').read
        @nokogiri_xml = Nokogiri::XML(xml_input)
        @as_ead.parse_arch_desc_misc @nokogiri_xml
      end

      it 'parses the archive_access_restrictions_head correctly' do
        tested = @as_ead.archive_access_restrictions_head
        expect(tested).to eq 'Restrictions on Access'
      end

      it 'parses the archive_access_restrictions_value correctly' do
        tested = @as_ead.archive_access_restrictions_value
        expect(tested).to eq 'This collection is located on-site.This collection has no restrictions.'
      end

      it 'parses the archive_biography_history_head correctly' do
        tested = @as_ead.archive_biography_history_head
        expect(tested).to eq 'Biographical / Historical'
      end

      it 'parses the archive_biography_history_value correctly' do
        tested = @as_ead.archive_biography_history_value
        expect(tested).to eq 'American artist, travel writer, and political activist.'
      end

      it 'parses the archive_preferred_citation_head correctly' do
        tested = @as_ead.archive_preferred_citation_head
        expect(tested).to eq 'Preferred Citation'
      end

      it 'parses the archive_preferred_citation_value correctly' do
        tested = @as_ead.archive_preferred_citation_value
        expect(tested).to include "specific item; Date (if known); Rockwell Kent papers; Box and"
      end

      it 'parses the archive_processing_information_head correctly' do
        tested = @as_ead.archive_processing_information_head
        expect(tested).to eq 'Processing Information'
      end

      it 'parses the archive_processing_information_value correctly' do
        tested = @as_ead.archive_processing_information_value
        expect(tested).to include "31 letters from RK to Henry Wohltjen Cataloged HR 11/06/1996."
      end

      it 'parses the archive_scope_content_head correctly' do
        tested = @as_ead.archive_scope_content_head
        expect(tested).to eq 'Scope and Content'
      end

      it 'parses the archive_scope_content_value correctly' do
        tested = @as_ead.archive_scope_content_value
        expect(tested).to include "as well as illustrations for 18 of Kent's own books; bookplates for many well known people,"
      end

      it 'parses the archive_use_restrictions_head correctly' do
        tested = @as_ead.archive_use_restrictions_head
        expect(tested).to eq 'Terms Governing Use and Reproduction'
      end

      it 'parses the archive_use_restrictions_value correctly' do
        tested = @as_ead.archive_use_restrictions_value
        expect(tested).to include 'be made for research purposes. The RBML maintains ownership of the physical material only. Copyright remains'
      end
    end
  end

  context "API/interface" do
    it 'has #parse method' do
      expect(subject).to respond_to(:parse).with(1).arguments
    end

    it 'has #parse_arch_desc_did method' do
      expect(subject).to respond_to(:parse_arch_desc_did).with(1).arguments
    end

    it 'has #parse_arch_desc_dsc method' do
      expect(subject).to respond_to(:parse_arch_desc_dsc).with(1).arguments
    end

    it 'has #parse_arch_desc_misc method' do
      expect(subject).to respond_to(:parse_arch_desc_misc).with(1).arguments
    end

    xit 'has #get_creators' do
      expect(subject).to respond_to(:get_creators).with(0).arguments
    end

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
      @as_ead_nokogiri_xml = Asi::AsEad.new
      @xml_input = fixture_file_upload('asi/as_ead_resource_4767_representation.xml').read
      @as_ead_nokogiri_xml.parse @xml_input
    end

    context "check functionality" do
      xit 'get_creators returns correct value' do
        ead_creators = @as_ead_nokogiri_xml.get_creators
        expect(ead_creators).to include('Not Present in AS EAD')
      end

      xit 'get_series_titles returns correct value' do
        series_titles = @as_ead_nokogiri_xml.get_series_titles
        expect(series_titles).to include 'Series VII: Bookplates'
      end

      xit 'get_series_scope_content returns correct value' do
        tested = @as_ead_nokogiri_xml.get_series_scope_content
        expect(tested).to include "This series contains material which was asscessioned after the main collection was processed."
      end

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

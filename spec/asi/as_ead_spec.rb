require 'rails_helper'
require 'asi/as_ead.rb'

attributes = [
  :archive_abstract, # <ead>:<archdesc>:<did>:<abstract>
  :archive_access_restrictions_head, # <ead>:<archdesc>:<accessrestrict>:<head>
  :archive_access_restrictions_value, # <ead>:<archdesc>:<accessrestrict>:<p>
  :archive_biography_history_head, # <ead>:<archdesc>:<bioghist>:<head>
  :archive_biography_history_value, # <ead>:<archdesc>:<bioghist>:<p>
  :archive_date, # <ead>:<archdesc>:<did>:<unitdate>
  :archive_dsc_series, # <ead>:<archdesc>:<dsc>:<c level=series>, returns array of series
  :archive_dsc_series_titles, # <ead>:<archdesc>:<dsc>:<c level=series><did><unittitle>, returns array of titles
  :archive_id, # <ead>:<archdesc>:<did>:<unitid>
  :archive_language, # <ead>:<archdesc>:<did>:<langmaterial><language>
  :archive_physical_description_extent_carrier, # <ead>:<archdesc>:<did>:<physdesc>:<extent @altrender="carrier">
  :archive_preferred_citation_head, # <ead>:<archdesc>:<prefercite>:<head>
  :archive_preferred_citation_value, # <ead>:<archdesc>:<prefercite>:<p>
  :archive_processing_information_head, # <ead>:<archdesc>:<processinfo>:<head>
  :archive_processing_information_value, # <ead>:<archdesc>:<processinfo>:<p>
  :archive_repository, # <ead><archdesc><did><repository><corpname>
  :archive_scope_content_head, # <ead>:<archdesc>:<scopecontent>:<head>
  :archive_scope_content_value, # <ead>:<archdesc>:<scopecontent>:<p>
  :archive_title, # <ead>:<archdesc>:<did>:<unititle>
  :archive_use_restrictions_head, # <ead>:<archdesc>:<userestrict>:<head>
  :archive_use_restrictions_value # <ead>:<archdesc>:<userestrict>:<p>
].freeze


RSpec.describe Asi::AsEad do
  ########################################## API/interface
  describe 'API/interface' do
    before(:context) do
      xml_input = fixture_file_upload('asi/as_ead_resource_4767_representation.xml').read
      @as_ead = Asi::AsEad.new xml_input
    end

    context 'has attr_reader for instance var' do
      attributes.each do |attribute|
        it "#{attribute}" do
          expect(@as_ead).to respond_to("#{attribute}")
        end
      end
    end

    context 'has ' do
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

  ########################################## Debug API/interface
  describe 'debug API/interface' do
    before(:context) do
      xml_input = fixture_file_upload('asi/as_ead_resource_4767_representation.xml').read
      @as_ead = Asi::AsEad.new xml_input
    end

    context 'has debug_attr_reader for instance var' do
      attributes.each do |attribute|
        it "#{attribute}" do
          expect(@as_ead).to respond_to("debug_#{attribute}")
        end
      end
    end
  end

  ########################################## Functionality
  describe 'Testing functionality: ' do
    before(:context) do
      xml_input = fixture_file_upload('asi/as_ead_resource_4767_representation.xml').read
      @as_ead = Asi::AsEad.new xml_input
      nokogiri_xml = Nokogiri::XML(xml_input)
      # @as_ead.parse_arch_desc_dsc nokogiri_xml
    end

    ########################################## parse_arch_desc_dsc
    # fcd1, 03//11/19: method probably needs renaming and refactoring
    context 'get_files_info_for_series' do
      it 'returns correct list of file titles and associated box number' do
        tested = @as_ead.get_files_info_for_series 1
        expect(tested).to include({:title => 'Price, Arthur: to Rockwell Kent, t.l.s., 15', :box_number => '3'})
      end
    end

    ########################################## parse_arch_desc_did
    context 'parse_arch_desc_did' do
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
      xml_input = fixture_file_upload('asi/as_ead_resource_4767_representation.xml').read
      @as_ead_nokogiri_xml = Asi::AsEad.new xml_input
    end

    context "check functionality" do
      xit 'get_creators returns correct value' do
        ead_creators = @as_ead_nokogiri_xml.get_creators
        expect(ead_creators).to include('Not Present in AS EAD')
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

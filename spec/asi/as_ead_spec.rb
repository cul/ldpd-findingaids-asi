require 'rails_helper'
require 'asi/as_ead.rb'

RSpec.describe Asi::AsEad do
  context "API/interface" do
    it 'has #parse method' do
      expect(subject).to respond_to(:parse).with(1).arguments
    end

    it 'has #get_ead_title' do
      expect(subject).to respond_to(:get_ead_title).with(0).arguments
    end

    it 'has #get_ead_abstract' do
      expect(subject).to respond_to(:get_ead_abstract).with(0).arguments
    end

    it 'has #get_bib_id' do
      expect(subject).to respond_to(:get_bib_id).with(0).arguments
    end

    it 'has #get_creators' do
      expect(subject).to respond_to(:get_creators).with(0).arguments
    end

    it 'has #get_unit_date' do
      expect(subject).to respond_to(:get_unit_date).with(0).arguments
    end

    it 'has #get_physical_description_extent' do
      expect(subject).to respond_to(:get_physical_description_extent).with(0).arguments
    end

    it 'has #get_lang_material' do
      expect(subject).to respond_to(:get_lang_material).with(0).arguments
    end

    it 'has #get_access_restrictions_head' do
      expect(subject).to respond_to(:get_access_restrictions_head).with(0).arguments
    end

    it 'has #get_access_restrictions_value' do
      expect(subject).to respond_to(:get_access_restrictions_value).with(0).arguments
    end

    it 'has #get_series_titles' do
      expect(subject).to respond_to(:get_series_titles).with(0).arguments
    end

    # this might not be needed if label/head is also gonna be the same
    it 'has #get_scope_content_head' do
      expect(subject).to respond_to(:get_scope_content_head).with(0).arguments
    end

    it 'has #get_scope_content_value' do
      expect(subject).to respond_to(:get_scope_content_value).with(0).arguments
    end

    it 'has #get_series_scope_content' do
      expect(subject).to respond_to(:get_series_scope_content).with(0).arguments
    end

    it 'has #get_repository_corpname' do
      expect(subject).to respond_to(:get_repository_corpname).with(0).arguments
    end

    it 'has #get_prefer_cite_head' do
      expect(subject).to respond_to(:get_prefer_cite_head).with(0).arguments
    end

    it 'has #get_prefer_cite_value' do
      expect(subject).to respond_to(:get_prefer_cite_value).with(0).arguments
    end

    it 'has #get_use_restrict_head' do
      expect(subject).to respond_to(:get_use_restrict_head).with(0).arguments
    end

    it 'has #get_use_restrict_value' do
      expect(subject).to respond_to(:get_use_restrict_value).with(0).arguments
    end

    it 'has #get_process_info_head' do
      expect(subject).to respond_to(:get_process_info_head).with(0).arguments
    end

    it 'has #get_process_info_value' do
      expect(subject).to respond_to(:get_process_info_value).with(0).arguments
    end

    it 'has #get_subjects' do
      expect(subject).to respond_to(:get_subjects).with(0).arguments
    end

    it 'has #get_genres_forms' do
      expect(subject).to respond_to(:get_genres_forms).with(0).arguments
    end

    it 'has #get_files_info_for_series' do
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
      it 'get_ead_title returns correct value' do
        # puts @xml_input
        ead_title = @as_ead_nokogiri_xml.get_ead_title
        expect(ead_title).to eq 'Rockwell Kent papers'
      end

      it 'get_ead_abstract returns correct value' do
        # puts @xml_input
        ead_abstract = @as_ead_nokogiri_xml.get_ead_abstract
        expect(ead_abstract).to include('drawings and sketches; watercolors; lithographs; proofs; manuscripts;')
      end

      it 'get_bib_id returns correct value' do
        bib_id = @as_ead_nokogiri_xml.get_bib_id
        expect(bib_id).to eq '4079547'
      end

      it 'get_creators returns correct value' do
        ead_creators = @as_ead_nokogiri_xml.get_creators
        expect(ead_creators).to include('Not Present in AS EAD')
      end

      it 'get_unit_date returns correct value' do
        ead_unit_date = @as_ead_nokogiri_xml.get_unit_date
        expect(ead_unit_date).to eq '1885-1970'
      end

      it 'get_physical_description_extent returns correct value' do
        physical_desc_extent = @as_ead_nokogiri_xml.get_physical_description_extent
        expect(physical_desc_extent).to eq '59 linear feet 46 boxes 10 drawers 3 slip cases'
      end

      it 'get_lang_material returns correct value' do
        lang_material = @as_ead_nokogiri_xml.get_lang_material
        expect(lang_material).to eq 'English'
      end

      it 'get_access_restrictions_head returns correct value' do
        tested = @as_ead_nokogiri_xml.get_access_restrictions_head
        expect(tested).to eq 'Restrictions on Access'
      end

      it 'get_access_restrictions_value returns correct value' do
        tested = @as_ead_nokogiri_xml.get_access_restrictions_value
        expect(tested).to eq 'This collection is located on-site.'
      end

      it 'get_series_titles returns correct value' do
        series_titles = @as_ead_nokogiri_xml.get_series_titles
        expect(series_titles).to include 'Series VII: Bookplates'
      end

      it 'get_scope_content_head returns correct value' do
        tested = @as_ead_nokogiri_xml.get_scope_content_head
        expect(tested).to eq 'Scope and Content'
      end

      it 'get_scope_content_value returns correct value' do
        tested = @as_ead_nokogiri_xml.get_scope_content_value
        expect(tested).to include " as well as many lithographs and woodblock prints by Kent's"
      end

      it 'get_series_scope_content returns correct value' do
        tested = @as_ead_nokogiri_xml.get_series_scope_content
        expect(tested).to include "This series contains material which was asscessioned after the main collection was processed."
      end

      it 'get_repository_corpname returns correct value' do
        tested = @as_ead_nokogiri_xml.get_repository_corpname
        expect(tested).to include "Rare Book and Manuscript Library"
      end

      it 'get_prefer_cite_head returns correct value' do
        tested = @as_ead_nokogiri_xml.get_prefer_cite_head
        expect(tested).to eq "Preferred Citation"
      end

      it 'get_prefer_cite_value returns correct value' do
        tested = @as_ead_nokogiri_xml.get_prefer_cite_value
        expect(tested).to eq "Identification of specific item; Date (if known); Rockwell Kent papers; Box and Folder; Rare Book and Manuscript Library, Columbia University Library."
      end

      it 'get_use_restrict_head returns correct value' do
        tested = @as_ead_nokogiri_xml.get_use_restrict_head
        expect(tested).to eq "Terms Governing Use and Reproduction"
      end

      it 'get_use_restrict_value returns correct value' do
        tested = @as_ead_nokogiri_xml.get_use_restrict_value
        expect(tested).to eq "Single photocopies may be made for research purposes. The RBML maintains ownership of the physical material only. Copyright remains with the creator and his/her heirs. The responsibility to secure copyright permission rests with the patron."
      end

      it 'get_process_info_head returns correct value' do
        tested = @as_ead_nokogiri_xml.get_process_info_head
        expect(tested).to eq "Processing Information"
      end

      it 'get_use_restrict_value returns correct value' do
        tested = @as_ead_nokogiri_xml.get_process_info_value
        expect(tested).to include "31 letters from RK to Henry Wohltjen Cataloged HR 11/06/1996."
      end

      it 'get_subjects returns correct value' do
        tested = @as_ead_nokogiri_xml.get_subjects
        expect(tested).to include 'Graphic arts'
      end

      it 'get_genres_forms returns correct value' do
        tested = @as_ead_nokogiri_xml.get_genres_forms
        expect(tested).to include 'Lithographs'
      end

      it 'get_files_info_for_series' do
        tested = @as_ead_nokogiri_xml.get_files_info_for_series 2
        expect(tested).to include({:title=>"Gag, Wanda Hazel.  [Spinning wheel], lithograph, (10.75\" x 9\")", :box_number=> "13V-F-01"})
      end
    end
  end
end

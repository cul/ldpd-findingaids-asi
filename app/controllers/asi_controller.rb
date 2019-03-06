require 'asi/as_api'
require 'asi/as_ead'

class AsiController < ApplicationController
  def as_ead_from_fixture
    @asi_api = Asi::AsApi.new
    @input_xml = @asi_api.get_ead_resource_description_from_fixture
    ead_set_properties
#    render 'ead'    
  end

  def as_ead
    @asi_api = Asi::AsApi.new
    @input_xml = @asi_api.get_ead_resource_description(params[:repo_id],params[:res_id])
    ead_set_properties
  end

  private
  def ead_set_properties
    @asi_ead_nokogiri_xml = Asi::AsEad.new
    @asi_ead_nokogiri_xml.parse @input_xml
    @ead_title = @asi_ead_nokogiri_xml.get_ead_title
    @ead_abstract = @asi_ead_nokogiri_xml.get_ead_abstract
    @ead_bib_id = @asi_ead_nokogiri_xml.get_bib_id
    @ead_creators = @asi_ead_nokogiri_xml.get_creators
    @ead_unit_date = @asi_ead_nokogiri_xml.get_unit_date
    @ead_physical_description = @asi_ead_nokogiri_xml.get_physical_description_extent
    @ead_language = @asi_ead_nokogiri_xml.get_lang_material
    @ead_access_restrictions_head = @asi_ead_nokogiri_xml.get_access_restrictions_head
    @ead_access_restrictions_value = @asi_ead_nokogiri_xml.get_access_restrictions_value
    @ead_series_titles = @asi_ead_nokogiri_xml.get_series_titles
    @ead_scope_content_head = @asi_ead_nokogiri_xml.get_scope_content_head
    @ead_scope_content_value = @asi_ead_nokogiri_xml.get_scope_content_value
    @ead_series_scope_content = @asi_ead_nokogiri_xml.get_series_scope_content
    @ead_repository_corpname = @asi_ead_nokogiri_xml.get_repository_corpname
    @ead_use_restrictions_head = @asi_ead_nokogiri_xml.get_use_restrict_head
    @ead_use_restrictions_value = @asi_ead_nokogiri_xml.get_use_restrict_value
    @ead_preferred_citation_head = @asi_ead_nokogiri_xml.get_prefer_cite_head
    @ead_preferred_citation_value = @asi_ead_nokogiri_xml.get_prefer_cite_value
    @ead_processing_information_head = @asi_ead_nokogiri_xml.get_process_info_head
    @ead_processing_information_value = @asi_ead_nokogiri_xml.get_process_info_value
    @ead_subjects = @asi_ead_nokogiri_xml.get_subjects
    @ead_genres_forms = @asi_ead_nokogiri_xml.get_genres_forms
  end
end

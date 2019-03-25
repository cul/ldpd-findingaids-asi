require 'asi/as_api'
require 'asi/as_ead'
require 'asi/as_ead_component'

class AsiController < ApplicationController
  def as_ead
    @asi_api = Asi::AsApi.new
    @input_xml = @asi_api.get_ead_resource_description(params[:repo_id],params[:res_id])
    ead_set_properties
  end

  def as_ead_debug
    @asi_api = Asi::AsApi.new
    @input_xml = @asi_api.get_ead_resource_description(params[:repo_id],params[:res_id])
    ead_set_properties_debug
  end

  def as_ead_from_local_fixture
    @asi_api = Asi::AsApi.new
    @input_xml =
      @asi_api.get_ead_resource_description_from_local_fixture(params[:repo_id],params[:res_id])
    ead_set_properties
  end

  def as_ead_from_local_fixture_debug
    @asi_api = Asi::AsApi.new
    @input_xml =
      @asi_api.get_ead_resource_description_from_local_fixture(params[:repo_id],params[:res_id])
    ead_set_properties_debug
  end

  def as_ead_series
    @asi_api = Asi::AsApi.new
    @input_xml = @asi_api.get_ead_resource_description(params[:repo_id],params[:res_id])
    ead_series_set_properties params[:ser_id]
  end

  def as_ead_series_from_local_fixture
    @asi_api = Asi::AsApi.new
    @input_xml =
      @asi_api.get_ead_resource_description_from_local_fixture(params[:repo_id],params[:res_id])
    ead_series_set_properties params[:ser_id]
  end

  def as_ead_from_fixture
    @asi_api = Asi::AsApi.new
    @input_xml = @asi_api.get_ead_resource_description_from_fixture
    ead_set_properties
  end

  private
  def ead_set_properties
    @asi_ead = Asi::AsEad.new @input_xml
    @ead_title = @asi_ead.archive_title
    @ead_abstract = @asi_ead.archive_abstract
    @ead_bib_id = @asi_ead.archive_id
    @ead_creators = @asi_ead.get_creators
    @ead_unit_date = @asi_ead.archive_date
    @ead_physical_description = @asi_ead.archive_physical_description_extent_carrier
    @ead_language = @asi_ead.archive_language
    @ead_access_restrictions_head = @asi_ead.archive_access_restrictions_head
    @ead_access_restrictions_value = @asi_ead.archive_access_restrictions_value
    @ead_scope_content_head = @asi_ead.archive_scope_content_head
    @ead_scope_content_value = @asi_ead.archive_scope_content_value
    @ead_repository_corpname = @asi_ead.archive_repository
    @ead_preferred_citation_head = @asi_ead.archive_preferred_citation_head
    @ead_preferred_citation_value = @asi_ead.archive_preferred_citation_value
    @ead_use_restrictions_head = @asi_ead.archive_use_restrictions_head
    @ead_use_restrictions_value = @asi_ead.archive_use_restrictions_value
    @ead_processing_information_head = @asi_ead.archive_processing_information_head
    @ead_processing_information_value = @asi_ead.archive_processing_information_value
    @ead_biography_history_head = @asi_ead.archive_biography_history_head
    @ead_biography_history_value = @asi_ead.archive_biography_history_value
    @ead_series_titles = @asi_ead.archive_dsc_series_titles
    @ead_series_scope_content = @asi_ead.get_series_scope_content
    @ead_subjects = @asi_ead.get_subjects
    @ead_genres_forms = @asi_ead.get_genres_forms
  end

  def ead_set_properties_debug
    @asi_ead = Asi::AsEad.new @input_xml
    @ead_title = @asi_ead.debug_archive_title
    @ead_abstract = @asi_ead.debug_archive_abstract
    @ead_bib_id = @asi_ead.debug_archive_id
    @ead_creators = @asi_ead.get_creators
    @ead_unit_date = @asi_ead.debug_archive_date
    @ead_physical_description = @asi_ead.debug_archive_physical_description_extent_carrier
    @ead_language = @asi_ead.debug_archive_language
    @ead_access_restrictions_head = @asi_ead.debug_archive_access_restrictions_head
    @ead_access_restrictions_value = @asi_ead.debug_archive_access_restrictions_value
    @ead_scope_content_head = @asi_ead.debug_archive_scope_content_head
    @ead_scope_content_value = @asi_ead.debug_archive_scope_content_value
    @ead_repository_corpname = @asi_ead.debug_archive_repository
    @ead_preferred_citation_head = @asi_ead.debug_archive_preferred_citation_head
    @ead_preferred_citation_value = @asi_ead.debug_archive_preferred_citation_value
    @ead_use_restrictions_head = @asi_ead.debug_archive_use_restrictions_head
    @ead_use_restrictions_value = @asi_ead.debug_archive_use_restrictions_value
    @ead_processing_information_head = @asi_ead.debug_archive_processing_information_head
    @ead_processing_information_value = @asi_ead.debug_archive_processing_information_value
    @ead_biography_history_head = @asi_ead.debug_archive_biography_history_head
    @ead_biography_history_value = @asi_ead.debug_archive_biography_history_value
    # fcd1, 03/15/19: TODO: see if debug info for titles is feasible.
    @ead_series_titles = @asi_ead.archive_dsc_series_titles
    @ead_series_scope_content = @asi_ead.get_series_scope_content
    @ead_subjects = @asi_ead.get_subjects
    @ead_genres_forms = @asi_ead.get_genres_forms
  end

  def ead_series_set_properties series_num
    @asi_ead = Asi::AsEad.new @input_xml
    @ead_series_files_info = @asi_ead.get_files_info_for_series series_num
    # @ead_series_titles is repeated in above method, so try to DRY
    @ead_series_titles = @asi_ead.archive_dsc_series_titles
    series_nokogiri_xml = @asi_ead.archive_dsc_series[series_num.to_i - 1]
    @as_ead_series = Asi::AsEadComponent.new
    @as_ead_series.parse series_nokogiri_xml
    @series_title = @as_ead_series.title
    @series_scope_content = @as_ead_series.scope_content
    @series_html = @asi_ead.generate_html_from_component(series_nokogiri_xml, '')
  end
end

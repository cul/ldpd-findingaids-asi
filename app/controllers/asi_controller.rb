require 'asi/as_api'
require 'asi/as_ead'
require 'asi/as_ead_component'

class AsiController < ApplicationController
  def as_ead
    @as_api = Asi::AsApi.new
    @input_xml = @as_api.get_ead_resource_description(params[:repo_id],params[:res_id])
    ead_set_properties
  end

  def as_ead_debug
    @as_api = Asi::AsApi.new
    @input_xml = @as_api.get_ead_resource_description(params[:repo_id],params[:res_id])
    ead_set_properties_debug
  end

  def as_ead_from_local_fixture
    @as_api = Asi::AsApi.new
    @input_xml =
      @as_api.get_ead_resource_description_from_local_fixture(params[:repo_id],params[:res_id])
    ead_set_properties
  end

  def as_ead_from_local_fixture_debug
    @as_api = Asi::AsApi.new
    @input_xml =
      @as_api.get_ead_resource_description_from_local_fixture(params[:repo_id],params[:res_id])
    ead_set_properties_debug
  end

  def as_ead_series
    @as_api = Asi::AsApi.new
    @input_xml = @as_api.get_ead_resource_description(params[:repo_id],params[:res_id])
    ead_series_set_properties params[:ser_id]
  end

  def as_ead_series_from_local_fixture
    @as_api = Asi::AsApi.new
    @input_xml =
      @as_api.get_ead_resource_description_from_local_fixture(params[:repo_id],params[:res_id])
    ead_series_set_properties params[:ser_id]
  end

  def as_ead_from_fixture
    @as_api = Asi::AsApi.new
    @input_xml = @as_api.get_ead_resource_description_from_fixture
    ead_set_properties
  end

  private
  def ead_set_properties
    @ead = Asi::AsEad.new @input_xml
    @title = @ead.archive_title
    @abstract = @ead.archive_abstract
    @bib_id = @ead.archive_id
    @creators = @ead.get_creators
    @unit_date = @ead.archive_date
    @physical_description = @ead.archive_physical_description_extent_carrier
    @language = @ead.archive_language
    @access_restrictions_head = @ead.archive_access_restrictions_head
    @access_restrictions_value = @ead.archive_access_restrictions_value
    @scope_content_head = @ead.archive_scope_content_head
    @scope_content_value = @ead.archive_scope_content_value
    @repository_corpname = @ead.archive_repository
    @preferred_citation_head = @ead.archive_preferred_citation_head
    @preferred_citation_value = @ead.archive_preferred_citation_value
    @use_restrictions_head = @ead.archive_use_restrictions_head
    @use_restrictions_value = @ead.archive_use_restrictions_value
    @processing_information_head = @ead.archive_processing_information_head
    @processing_information_value = @ead.archive_processing_information_value
    @biography_history_head = @ead.archive_biography_history_head
    @biography_history_value = @ead.archive_biography_history_value
    @series_titles = @ead.archive_dsc_series_titles
    @series_scope_content = @ead.get_series_scope_content
    @subjects = @ead.get_subjects
    @genres_forms = @ead.get_genres_forms
  end

  def ead_set_properties_debug
    @ead = Asi::AsEad.new @input_xml
    @title = @ead.debug_archive_title
    @abstract = @ead.debug_archive_abstract
    @bib_id = @ead.debug_archive_id
    @creators = @ead.get_creators
    @unit_date = @ead.debug_archive_date
    @physical_description = @ead.debug_archive_physical_description_extent_carrier
    @language = @ead.debug_archive_language
    @access_restrictions_head = @ead.debug_archive_access_restrictions_head
    @access_restrictions_value = @ead.debug_archive_access_restrictions_value
    @scope_content_head = @ead.debug_archive_scope_content_head
    @scope_content_value = @ead.debug_archive_scope_content_value
    @repository_corpname = @ead.debug_archive_repository
    @preferred_citation_head = @ead.debug_archive_preferred_citation_head
    @preferred_citation_value = @ead.debug_archive_preferred_citation_value
    @use_restrictions_head = @ead.debug_archive_use_restrictions_head
    @use_restrictions_value = @ead.debug_archive_use_restrictions_value
    @processing_information_head = @ead.debug_archive_processing_information_head
    @processing_information_value = @ead.debug_archive_processing_information_value
    @biography_history_head = @ead.debug_archive_biography_history_head
    @biography_history_value = @ead.debug_archive_biography_history_value
    # fcd1, 03/15/19: TODO: see if debug info for titles is feasible.
    @series_titles = @ead.archive_dsc_series_titles
    @series_scope_content = @ead.get_series_scope_content
    @subjects = @ead.get_subjects
    @genres_forms = @ead.get_genres_forms
  end

  def ead_series_set_properties component_num
    @ead = Asi::AsEad.new @input_xml
    @series_files_info = @ead.get_files_info_for_series component_num
    # @ead_series_titles is repeated in above method, so try to DRY
    @series_titles = @ead.archive_dsc_series_titles
    component_nokogiri_xml = @ead.archive_dsc_series[component_num.to_i - 1]
    @component = Asi::AsEadComponent.new
    @component.parse component_nokogiri_xml
    @component_title = @component.title
    @component_scope_content = @component.scope_content_value
    @component_html = @component.generate_html
  end
end

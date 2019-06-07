require 'archive_space/api/client'
require 'archive_space/ead/ead_parser'
require 'archive_space/ead/ead_component_parser'

class ComponentsController < ApplicationController
  include  ArchiveSpace::Ead::EadHelper

  before_action :set_bib_id,
                :validate_repository_code_and_set_repo_id,
                :validate_bib_id_and_set_resource_id

  def index
    if CONFIG[:use_fixtures]
      @input_xml =
        @as_api.get_ead_resource_description_from_local_fixture(@as_repo_id,@as_resource_id)
    else
      @input_xml = @as_api.get_ead_resource_description(@as_repo_id,@as_resource_id)
    end
    @ead = ArchiveSpace::Ead::EadParser.new @input_xml
    @finding_aid_title =
      [@ead.unit_title, @ead.compound_dates_into_string(@ead.unit_dates)].join(', ')
    @series_titles = @ead.dsc_series_titles
    @subseries_titles = @ead.subseries_titles
    # @creator, @item_date, and @repository_name used when sending aeon request
    @creator = @ead.origination_creators.first.text unless  @ead.origination_creators.first.nil?
    @item_date = @ead.unit_dates.first.text unless  @ead.unit_dates.first.nil?
    @repository_name = @ead.repository
    @restricted_access_flag =
      @ead.access_restrictions_values.map{ |value| hightlight_offsite value.text }.any?
    @notes_array = []
    @flattened_component_structure_array = []
    @series_titles.each_with_index do |title, index|
      ead_series_set_properties(index + 1)
      @notes_array.append @notes
      @flattened_component_structure_array.append @flattened_component_structure
    end
  end

  def show
    if CONFIG[:use_fixtures]
      @input_xml =
        @as_api.get_ead_resource_description_from_local_fixture(@as_repo_id,@as_resource_id)
    else
      @input_xml = @as_api.get_ead_resource_description(@as_repo_id,@as_resource_id)
    end
    @ead = ArchiveSpace::Ead::EadParser.new @input_xml
    @finding_aid_title =
      [@ead.unit_title, @ead.compound_dates_into_string(@ead.unit_dates)].join(', ')
    @series_titles = @ead.dsc_series_titles
    @subseries_titles = @ead.subseries_titles
    # @creator, @item_date, and @repository_name used when sending aeon request
    @creator = @ead.origination_creators.first.text unless  @ead.origination_creators.first.nil?
    @item_date = @ead.unit_dates.first.text unless  @ead.unit_dates.first.nil?
    @repository_name = @ead.repository
    @restricted_access_flag =
      @ead.access_restrictions_values.map{ |value| hightlight_offsite value.text }.any?
    ead_series_set_properties params[:id]
  end

  private
  def ead_series_set_properties component_num
    component_nokogiri_xml = @ead.dsc_series[component_num.to_i - 1]
    @component = ArchiveSpace::Ead::EadComponentParser.new
    @component.parse component_nokogiri_xml
    @component_title = @component.title
    @notes = @component.notes
    @flattened_component_structure = @component.generate_info
  end

  def set_bib_id
    @bib_id = params[:finding_aid_id].delete_prefix('ldpd_').to_i
  end
end

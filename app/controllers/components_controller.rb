require 'archive_space/api/client'
require 'archive_space/ead/ead_parser'
require 'archive_space/ead/ead_component_parser'

class ComponentsController < ApplicationController
  include  ArchiveSpace::Ead::EadHelper

  before_action :validate_repository_code_and_set_repo_id,
                :initialize_as_api,
                :get_as_resource_info,
                only: [:index, :show]

  def index
    if @preview_flag
      Rails.logger.warn("Using Preview for #{params[:finding_aid_id]}")
      @input_xml = preview_as_ead params[:finding_aid_id].delete_prefix('ldpd_').to_i
    else
      Rails.logger.warn("Using Cache for #{params[:finding_aid_id]}")
      @input_xml = cached_as_ead params[:finding_aid_id].delete_prefix('ldpd_').to_i
    end
    @ead = ArchiveSpace::Ead::EadParser.new @input_xml
    @finding_aid_title =
      [@ead.unit_title, @ead.compound_dates_into_string(@ead.unit_dates)].join(', ')
    @series_titles = @ead.dsc_series_titles
    @subseries_titles = @ead.subseries_titles
    # @bib_id, @creator, @item_date, and @repository_name used when sending aeon request
    @bib_id = @ead.unit_id
    @creator = @ead.origination_creators.first.text unless  @ead.origination_creators.first.nil?
    @item_date = @ead.unit_dates.first.text unless  @ead.unit_dates.first.nil?
    @repository_name = @ead.repository
    @restricted_access_flag =
      @ead.access_restrictions_values.map{ |value| hightlight_offsite value.text }.any?
    @notes_array = []
    @flattened_component_structure_array = []
    @daos_description_href_array = []
    @series_titles.each_with_index do |title, index|
      ead_series_set_properties(index + 1)
      @notes_array.append @notes
      @flattened_component_structure_array.append @flattened_component_structure
      @daos_description_href_array.append @daos_description_href
    end
  end

  def show
    if @preview_flag
      Rails.logger.warn("Using Preview for #{params[:finding_aid_id]}")
      @input_xml = preview_as_ead params[:finding_aid_id].delete_prefix('ldpd_').to_i
    else
      Rails.logger.warn("Using Cache for #{params[:finding_aid_id]}")
      @input_xml = cached_as_ead params[:finding_aid_id].delete_prefix('ldpd_').to_i
    end
    @ead = ArchiveSpace::Ead::EadParser.new @input_xml
    @finding_aid_title =
      [@ead.unit_title, @ead.compound_dates_into_string(@ead.unit_dates)].join(', ')
    @series_titles = @ead.dsc_series_titles
    @subseries_titles = @ead.subseries_titles
    # @bib_id, @creator, @item_date, and @repository_name used when sending aeon request
    @bib_id = @ead.unit_id
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
    @daos_description_href = @component.digital_archival_objects_description_href
    @flattened_component_structure = @component.generate_info
  end

  def get_as_resource_info
    bib_id = params[:finding_aid_id].delete_prefix('ldpd_').to_i
    if CONFIG[:use_fixtures]
      @as_resource_id = @as_api.get_resource_id_local_fixture(bib_id)
    else
      @as_resource_id = @as_api.get_resource_id(@as_repo_id, bib_id)
    end
    unless @as_resource_id
      Rails.logger.warn('bib ID does not resolve to AS resource')
      redirect_to '/'
      return
    end
    unless CONFIG[:use_fixtures]
      @as_resource_info = @as_api.get_resource_info(@as_repo_id, @as_resource_id)
      Rails.logger.warn("AS resource #{@as_resource_id} system_mtime: #{@as_resource_info.modified_time}")
      Rails.logger.warn("AS resource #{@as_resource_id} publish: #{@as_resource_info.publish_flag}")
      unless @as_resource_info.publish_flag
        # fcd1, 06/17/19: For now, don't combine above conditional and below conditional in compound statement
        # because want to log specific messages for info/debug purposes
        if @preview_flag
          Rails.logger.warn("AS ID #{@as_resource_id} (Bib ID #{bib_id}): publish flag false, preview mode, DISPLAY")
        else
          Rails.logger.warn("AS ID #{@as_resource_id} (Bib ID #{bib_id}): publish flag false, DON'T DISPLAY")
          redirect_to '/'
          return
        end
      end
    end
  end
end

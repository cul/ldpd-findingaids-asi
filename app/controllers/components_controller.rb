require 'archive_space/api/client'
require 'archive_space/ead/ead_parser'
require 'archive_space/ead/ead_component_parser'

class ComponentsController < ApplicationController
  include  ArchiveSpace::Ead::EadHelper

  before_action :validate_repository_code_and_set_repo_id,
                :initialize_as_api,
                :get_as_resource_info,
                only: [:index, :show]
  after_action :cache_response_html, only: [:index, :show]

  def index
    @dsc_all = true
    if @preview_flag
      Rails.logger.info("Using Preview for #{params[:finding_aid_id]}")
      @input_xml = preview_as_ead params[:finding_aid_id].delete_prefix('ldpd_').to_i
      index_helper_process_ead
    else
      cached_html_filename = File.join(CONFIG[:html_cache_dir], "ldpd_#{@params_bib_id}_all.html")
      if File.exist?(cached_html_filename)
        Rails.logger.info("Using Cached HTML file for #{params[:finding_aid_id]}")
        cached_html_file = open(cached_html_filename) do |file|
          file.read
        end
        cached_html_file.sub!(CONFIG[:authenticity_token_placeholder], form_authenticity_token)
        render html: cached_html_file.html_safe
        return
      else
        @authenticity_token = form_authenticity_token
        Rails.logger.warn("Using EAD Cache for #{params[:finding_aid_id]} View All")
        @input_xml = cached_as_ead params[:finding_aid_id].delete_prefix('ldpd_').to_i
        index_helper_process_ead
      end
    end
  end

  def index_helper_process_ead
    @ead = ArchiveSpace::Ead::EadParser.new @input_xml
    @finding_aid_title =
      [@ead.unit_title, @ead.compound_dates_into_string(@ead.unit_dates)].join(', ')
    @series_titles = @ead.dsc_series_titles
    @subseries_titles = @ead.subseries_titles
    # @bib_id, @call_number, @creator, and @item_date used when sending aeon request
    @bib_id = @ead.unit_ids.first.text
    # EAD may or may not contain a second <unitid> containing call number
    @call_number = @ead.unit_ids[1].text unless @ead.unit_ids.size == 1
    @creator = @ead.origination_creators.first.text unless  @ead.origination_creators.first.nil?
    @item_date = @ead.unit_dates.first.text unless  @ead.unit_dates.first.nil?
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
    # @params_series_number used by html caching functionality
    @params_series_num = params[:id]
    if @preview_flag
      Rails.logger.info("Using Preview for #{params[:finding_aid_id]}")
      @input_xml = preview_as_ead params[:finding_aid_id].delete_prefix('ldpd_').to_i
      show_helper_process_ead
    else
      cached_html_filename = File.join(CONFIG[:html_cache_dir], "ldpd_#{@params_bib_id}_#{@params_series_num}.html")
      if File.exist?(cached_html_filename)
        Rails.logger.info("Using Cached HTML file for #{params[:finding_aid_id]} dsc #{@params_series_num}")
        cached_html_file = open(cached_html_filename) do |file|
          file.read
        end
        cached_html_file.sub!(CONFIG[:authenticity_token_placeholder], form_authenticity_token)
        render html: cached_html_file.html_safe
        return
      else
        @authenticity_token = form_authenticity_token
        Rails.logger.warn("Using EAD Cache for #{params[:finding_aid_id]} dsc #{@params_series_num}")
        @input_xml = cached_as_ead params[:finding_aid_id].delete_prefix('ldpd_').to_i
        show_helper_process_ead
      end
    end
  end

  def show_helper_process_ead
    @ead = ArchiveSpace::Ead::EadParser.new @input_xml
    # verify given series number (params[:id]) is within range
    unless (params[:id].to_i < @ead.dsc_series_titles.size + 1 && params[:id].to_i > 0)
      Rails.logger.warn('dsc number from url params out of range')
      redirect_to '/'
      return
    end
    @finding_aid_title =
      [@ead.unit_title, @ead.compound_dates_into_string(@ead.unit_dates)].join(', ')
    @series_titles = @ead.dsc_series_titles
    @subseries_titles = @ead.subseries_titles
    # @bib_id, @call_number, @creator, and @item_date used when sending aeon request
    @bib_id = @ead.unit_ids.first.text
    # EAD may or may not contain a second <unitid> containing call number
    @call_number = @ead.unit_ids[1].text unless @ead.unit_ids.size == 1
    @creator = @ead.origination_creators.first.text unless  @ead.origination_creators.first.nil?
    @item_date = @ead.unit_dates.first.text unless  @ead.unit_dates.first.nil?
    @restricted_access_flag =
      @ead.access_restrictions_values.map{ |value| hightlight_offsite value.text }.any?
    ead_series_set_properties params[:id]
  end

  def index_legacy_no_html_caching
    if @preview_flag
      Rails.logger.info("Using Preview for #{params[:finding_aid_id]}")
      @input_xml = preview_as_ead params[:finding_aid_id].delete_prefix('ldpd_').to_i
    else
      Rails.logger.warn("Using EAD Cache for #{params[:finding_aid_id]}")
      @input_xml = cached_as_ead params[:finding_aid_id].delete_prefix('ldpd_').to_i
    end
    @ead = ArchiveSpace::Ead::EadParser.new @input_xml
    @finding_aid_title =
      [@ead.unit_title, @ead.compound_dates_into_string(@ead.unit_dates)].join(', ')
    @series_titles = @ead.dsc_series_titles
    @subseries_titles = @ead.subseries_titles
    # @bib_id, @call_number, @creator, and @item_date used when sending aeon request
    @bib_id = @ead.unit_ids.first.text
    # EAD may or may not contain a second <unitid> containing call number
    @call_number = @ead.unit_ids[1].text unless @ead.unit_ids.size == 1
    @creator = @ead.origination_creators.first.text unless  @ead.origination_creators.first.nil?
    @item_date = @ead.unit_dates.first.text unless  @ead.unit_dates.first.nil?
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

  def show_legacy_no_html_caching
    if @preview_flag
      Rails.logger.info("Using Preview for #{params[:finding_aid_id]}")
      @input_xml = preview_as_ead params[:finding_aid_id].delete_prefix('ldpd_').to_i
    else
      Rails.logger.warn("Using EAD Cache for #{params[:finding_aid_id]}")
      @input_xml = cached_as_ead params[:finding_aid_id].delete_prefix('ldpd_').to_i
    end
    @ead = ArchiveSpace::Ead::EadParser.new @input_xml
    # verify given series number (params[:id]) is within range
    unless (params[:id].to_i < @ead.dsc_series_titles.size + 1 && params[:id].to_i > 0)
      Rails.logger.warn('dsc number from url params out of range')
      redirect_to '/'
      return
    end
    @finding_aid_title =
      [@ead.unit_title, @ead.compound_dates_into_string(@ead.unit_dates)].join(', ')
    @series_titles = @ead.dsc_series_titles
    @subseries_titles = @ead.subseries_titles
    # @bib_id, @call_number, @creator, and @item_date used when sending aeon request
    @bib_id = @ead.unit_ids.first.text
    # EAD may or may not contain a second <unitid> containing call number
    @call_number = @ead.unit_ids[1].text unless @ead.unit_ids.size == 1
    @creator = @ead.origination_creators.first.text unless  @ead.origination_creators.first.nil?
    @item_date = @ead.unit_dates.first.text unless  @ead.unit_dates.first.nil?
    @restricted_access_flag =
      @ead.access_restrictions_values.map{ |value| hightlight_offsite value.text }.any?
    ead_series_set_properties params[:id]
  end

  private
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
    # @params_bib_id used by html caching functionality
    @params_bib_id = bib_id.to_s
    unless CONFIG[:use_fixtures]
      @as_resource_info = @as_api.get_resource_info(@as_repo_id, @as_resource_id)
      Rails.logger.info("AS resource #{@as_resource_id} system_mtime: #{@as_resource_info.modified_time}")
      Rails.logger.info("AS resource #{@as_resource_id} publish: #{@as_resource_info.publish_flag}")
      unless @as_resource_info.publish_flag
        # fcd1, 06/17/19: For now, don't combine above conditional and below conditional in compound statement
        # because want to log specific messages for info/debug purposes
        if @preview_flag
          Rails.logger.info("AS ID #{@as_resource_id} (Bib ID #{bib_id}): publish flag false, preview mode, DISPLAY")
        else
          Rails.logger.warn("AS ID #{@as_resource_id} (Bib ID #{bib_id}): publish flag false, DON'T DISPLAY")
          redirect_to '/'
          return
        end
      end
    end
  end
end

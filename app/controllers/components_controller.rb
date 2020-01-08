require 'archive_space/api/client'
require 'archive_space/ead/ead_parser'
require 'archive_space/ead/ead_component_parser'

require 'archive_space/parsers/component_parser'
require 'archive_space/parsers/ead_parser'
require 'archive_space/parsers/archival_description_did_parser'
require 'archive_space/parsers/archival_description_dsc_parser'
require 'archive_space/parsers/archival_description_misc_parser'
require 'archive_space/parsers/ead_header_parser'

class ComponentsController < ApplicationController
  include  ArchiveSpace::Ead::EadHelper

  before_action :validate_repository_code_and_set_repo_id,
                only: [:index, :show]
  after_action :cache_response_html, only: [:index, :show]

  def show
    @authenticity_token = form_authenticity_token
    # @params_bib_id used by html caching functionality and error logging
    @params_bib_id = params[:finding_aid_id].delete_prefix('ldpd_').to_i
    # @params_series_number used by html caching functionality
    @params_series_num = params[:id]
    input_xml = render_cached_html_else_return_as_ead_xml(@params_bib_id, @authenticity_token)
    return unless input_xml
    ead_nokogiri_xml_doc = create_nokogiri_xml_document(input_xml, @params_bib_id)
    # need to parse the <archdesc><dsc> to get the list of top-level <c>s and enclosed second-level <c>s
    # in order to build the lhs sidebar navigation menu. Also used to verify given series number is within range
    @arch_desc_dsc = ArchiveSpace::Parsers::ArchivalDescriptionDscParser.new
    @arch_desc_dsc.parse ead_nokogiri_xml_doc
    # verify given series number (params[:id]) is within range
    unless (params[:id].to_i < @arch_desc_dsc.series_compound_title_array.size + 1 && params[:id].to_i > 0)
      Rails.logger.warn('dsc number from url params out of range')
      redirect_to '/'
      return
    end
    # Need top-level finding aids information for the aeon request and finding aids title
    @arch_desc_did = ArchiveSpace::Parsers::ArchivalDescriptionDidParser.new
    @arch_desc_did.parse ead_nokogiri_xml_doc
    @finding_aid_title =
      [@arch_desc_did.unit_title, @arch_desc_did.unit_dates_string].join(', ')
    # Need to parse miscellaneous info in the <archdesc> in order to get access restrictions. No need to
    # store it in an instance var, the pertinent info is retrieved to set flags below in current method
    arch_desc_misc = ArchiveSpace::Parsers::ArchivalDescriptionMiscParser.new
    arch_desc_misc.parse ead_nokogiri_xml_doc
    @restricted_access_flag =
      arch_desc_misc.access_restrictions_values.map{ |value| hightlight_offsite value.text }.any?
    @unprocessed_flag =
      arch_desc_misc.access_restrictions_values.map{ |value| accessrestrict_contains_unprocessed? value.text }.any?
    # fcd1, 09/12/19: For now, assume all top-level <c> elements are series. However, when other
    # types of top-level <c> elements are allowed, modify the following code, including changing
    # variable name from @series to, for example, @top_level_component (more generic), or check
    # for the type of component here and create appropriate variable
    @series = ArchiveSpace::Parsers::ComponentParser.new
    @series.parse(ead_nokogiri_xml_doc, @params_series_num.to_i)
    @cache_html = true unless @preview_flag
  end

  def index
    @dsc_all = true
    @authenticity_token = form_authenticity_token
    # @params_bib_id used by html caching functionality and error logging
    @params_bib_id = params[:finding_aid_id].delete_prefix('ldpd_').to_i
    input_xml = render_cached_html_else_return_as_ead_xml(@params_bib_id, @authenticity_token)
    return unless input_xml
    ead_nokogiri_xml_doc = create_nokogiri_xml_document(input_xml, @params_bib_id)
    @arch_desc_did = ArchiveSpace::Parsers::ArchivalDescriptionDidParser.new
    @arch_desc_did.parse ead_nokogiri_xml_doc
    @arch_desc_dsc = ArchiveSpace::Parsers::ArchivalDescriptionDscParser.new
    @arch_desc_dsc.parse ead_nokogiri_xml_doc
    @arch_desc_misc = ArchiveSpace::Parsers::ArchivalDescriptionMiscParser.new
    @arch_desc_misc.parse ead_nokogiri_xml_doc
    @ead_header = ArchiveSpace::Parsers::EadHeaderParser.new
    @ead_header.parse ead_nokogiri_xml_doc
    @finding_aid_title =
      [@arch_desc_did.unit_title, @arch_desc_did.unit_dates_string].join(', ')
    @subjects = (@arch_desc_misc.control_access_corporate_name_values +
                 @arch_desc_misc.control_access_occupation_values +
                 @arch_desc_misc.control_access_personal_name_values +
                 @arch_desc_misc.control_access_subject_values).sort
    @genres_forms = @arch_desc_misc.control_access_genre_form_values.sort
    @notes_array = []
    @flattened_component_structure_array = []
    @daos_description_href_array = []
    @series_array = []
    @arch_desc_dsc.series_compound_title_array.each_with_index do |title, index|
      # fcd1, 09/12/19: For now, assume all top-level <c> elements are series. However, when other
      # types of top-level <c> elements are allowed, modify the following code, including changing
      # variable name from a_series to, for example, a_top_level_component (more generic), or check
      # for the type of component here and create appropriate variable
      current_series = ArchiveSpace::Parsers::ComponentParser.new
      current_series.parse(ead_nokogiri_xml_doc, index + 1)
      @series_array.append current_series
    end
    @cache_html = true unless @preview_flag
  end

  def index_helper_process_ead
    begin
      @ead = ArchiveSpace::Ead::EadParser.new(@input_xml)
    rescue Nokogiri::XML::SyntaxError => e
      Rails.logger.error("Bib ID #{@params_bib_id}, Nokogiri parsing error:")
      Rails.logger.error("Nokogiri::XML::SyntaxError: #{e}")
      Rails.logger.error("Using Nokogiri recover mode for #{@params_bib_id}")
      # Nokogiri RECOVER parsing mode is recommended for malformed or invalid documents
      # setting second argument to true will use RECOVER mode when parsing xml
      @ead = ArchiveSpace::Ead::EadParser.new(@input_xml, true)
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

  def index_orig_17Jan20
    @dsc_all = true
    if @preview_flag
      Rails.logger.info("Using Preview for #{params[:finding_aid_id]}")
      @input_xml = preview_as_ead params[:finding_aid_id].delete_prefix('ldpd_').to_i
      index_helper_process_ead
    else
      # @params_bib_id used by html caching functionality
      @params_bib_id = params[:finding_aid_id].delete_prefix('ldpd_').to_i
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
    @cache_html = true unless @preview_flag
  end

  def show_orig_09Jan20
    # @params_series_number used by html caching functionality
    @params_series_num = params[:id]
    if @preview_flag
      Rails.logger.info("Using Preview for #{params[:finding_aid_id]}")
      @input_xml = preview_as_ead params[:finding_aid_id].delete_prefix('ldpd_').to_i
      show_helper_process_ead
    else
      # @params_bib_id used by html caching functionality
      @params_bib_id = params[:finding_aid_id].delete_prefix('ldpd_').to_i
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
    begin
      @ead = ArchiveSpace::Ead::EadParser.new(@input_xml)
    rescue Nokogiri::XML::SyntaxError => e
      Rails.logger.error("Bib ID #{@params_bib_id}, Nokogiri parsing error:")
      Rails.logger.error("Nokogiri::XML::SyntaxError: #{e}")
      Rails.logger.error("Using Nokogiri recover mode for #{@params_bib_id}")
      # Nokogiri RECOVER parsing mode is recommended for malformed or invalid documents
      # setting second argument to true will use RECOVER mode when parsing xml
      @ead = ArchiveSpace::Ead::EadParser.new(@input_xml, true)
    end
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
    @unprocessed_flag =
      @ead.access_restrictions_values.map{ |value| accessrestrict_contains_unprocessed? value.text }.any?
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

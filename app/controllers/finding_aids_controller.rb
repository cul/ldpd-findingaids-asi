require 'archive_space/api/client'
require 'archive_space/ead/ead_parser'
require 'archive_space/ead/ead_component_parser'
require 'archive_space/parsers/ead_parser'
require 'archive_space/parsers/archival_description_did_parser'
require 'archive_space/parsers/archival_description_dsc_parser'
require 'archive_space/parsers/archival_description_misc_parser'
require 'archive_space/parsers/ead_header_parser'
require 'archive_space/parsers/component_parser'

class FindingAidsController < ApplicationController
  include  ArchiveSpace::Ead::EadHelper

  before_action :validate_repository_code_and_set_repo_id, only: [:index, :print, :show]
  after_action :cache_response_html, only: [:show, :print]

  def index
    @repo_id = params[:repository_id]
    @finding_aids_titles_bib_ids = REPOS[@repo_id][:list_of_finding_aids]
  end

  def show
    # @params_bib_id used by html caching functionality and error logging
    @params_bib_id = params[:id].delete_prefix('ldpd_').to_i
    input_xml = render_cached_html_else_return_as_ead_xml @params_bib_id
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
    @restricted_access_flag =
      @arch_desc_misc.access_restrictions_values.map{ |value| hightlight_offsite value.text }.any?
    @unprocessed_flag =
      @arch_desc_misc.access_restrictions_values.map{ |value| accessrestrict_contains_unprocessed? value.text }.any?
    @cache_html = true unless @preview_flag
  end

  def print
    @print_view = true
    # @params_bib_id used by html caching functionality
    @params_bib_id = params[:finding_aid_id].delete_prefix('ldpd_').to_i
    input_xml = render_cached_html_else_return_as_ead_xml @params_bib_id
    return unless input_xml
    ead_nokogiri_xml_doc = create_nokogiri_xml_document(input_xml, @params_bib_id)
    # ead_set_properties
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
    @series_array = []
    @arch_desc_dsc.series_compound_title_array.each_with_index do |title, index|

      # fcd1, 01/12/19: old code below:
      # ead_series_set_properties(index + 1)
      # @notes_array.append @notes
      # @flattened_component_structure_array.append @flattened_component_structure
      # @daos_description_href_array.append @daos_description_href

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

  def summary
    if @preview_flag
      redirect_to '/preview' + repository_finding_aid_path(id: params[:finding_aid_id])
    else
      redirect_to repository_finding_aid_path(id: params[:finding_aid_id])
    end
  end

  def show_orig_07Jan20
    if @preview_flag
      Rails.logger.info("Using Preview for #{params[:id]}")
      @input_xml = preview_as_ead params[:id].delete_prefix('ldpd_').to_i
      ead_set_properties
    else
      # @params_bib_id used by html caching functionality
      @params_bib_id = params[:id].delete_prefix('ldpd_').to_i
      cached_html_filename = File.join(CONFIG[:html_cache_dir], "ldpd_#{@params_bib_id}.html")
      if File.exist?(cached_html_filename)
        Rails.logger.info("Using Cached HTML file for #{params[:id]}")
        cached_html_file = open(cached_html_filename) do |file|
          file.read
        end
        render html: cached_html_file.html_safe
        return
      else
        Rails.logger.warn("Using EAD Cache for #{params[:id]}")
        @input_xml = cached_as_ead @params_bib_id
        return unless @input_xml
        ead_set_properties
      end
    end
  end

  def print_orig_12Jan20
    @print_view = true
    # @params_bib_id used by html caching functionality
    @params_bib_id = params[:finding_aid_id].delete_prefix('ldpd_').to_i
    if @preview_flag
      Rails.logger.info("Using Preview for #{params[:finding_aid_id]} print view")
      @input_xml = preview_as_ead params[:finiding_aid_id].delete_prefix('ldpd_').to_i
    else
      Rails.logger.warn("Using EAD Cache for #{params[:finding_aid_id]} print view")
      @input_xml = cached_as_ead params[:finding_aid_id].delete_prefix('ldpd_').to_i
    end
    ead_set_properties
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

  private

  def ead_set_properties
    begin
      @ead = ArchiveSpace::Ead::EadParser.new(@input_xml, false, @params_bib_id)
    rescue Nokogiri::XML::SyntaxError => e
      Rails.logger.error("Bib ID #{@params_bib_id}, Nokogiri parsing error:")
      Rails.logger.error("Nokogiri::XML::SyntaxError: #{e}")
      Rails.logger.error("Using Nokogiri recover mode for #{@params_bib_id}")
      # Nokogiri RECOVER parsing mode is recommended for malformed or invalid documents
      # setting second argument to true will use RECOVER mode when parsing xml
      @ead = ArchiveSpace::Ead::EadParser.new(@input_xml, true, @params_bib_id)
    end
    @finding_aid_title =
      [@ead.unit_title, @ead.compound_dates_into_string(@ead.unit_dates)].join(', ')
    @bib_id = @ead.unit_ids.first.text
    # EAD may or may not contain a second <unitid> containing call number
    @call_number = @ead.unit_ids[1].text unless @ead.unit_ids.size == 1
    @physical_description_string = compound_physical_descriptions_into_string @ead.physical_descriptions
    @series_titles = @ead.dsc_series_titles
    @subseries_titles = @ead.subseries_titles
    @subjects = (@ead.control_access_corpnames +
                @ead.control_access_occupations +
                @ead.control_access_persnames +
                @ead.control_access_subjects).sort
    @genres_forms = @ead.control_access_genres_forms.sort
    @restricted_access_flag =
      @ead.access_restrictions_values.map{ |value| hightlight_offsite value.text }.any?
    @unprocessed_flag =
      @ead.access_restrictions_values.map{ |value| accessrestrict_contains_unprocessed? value.text }.any?
  end

  def get_as_resource_info
    if @print_view
      bib_id = params[:finding_aid_id].delete_prefix('ldpd_').to_i
    else
      bib_id = params[:id].delete_prefix('ldpd_').to_i
    end
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

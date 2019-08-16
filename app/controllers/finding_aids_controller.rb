require 'archive_space/api/client'
require 'archive_space/ead/ead_parser'
require 'archive_space/ead/ead_component_parser'

class FindingAidsController < ApplicationController
  include  ArchiveSpace::Ead::EadHelper

  before_action :validate_repository_code_and_set_repo_id, only: [:index, :print, :show]
  after_action :cache_response_html, only: [:show]

  def index
    @repo_id = params[:repository_id]
    @finding_aids_titles_bib_ids = REPOS[@repo_id][:list_of_finding_aids]
  end

  def show
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
        @input_xml = cached_as_ead params[:id].delete_prefix('ldpd_').to_i
        ead_set_properties
      end
    end
  end

  def summary
    if @preview_flag
      redirect_to '/preview' + repository_finding_aid_path(id: params[:finding_aid_id])
    else
      redirect_to repository_finding_aid_path(id: params[:finding_aid_id])
    end
  end

  def print
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

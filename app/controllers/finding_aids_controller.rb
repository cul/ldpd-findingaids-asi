require 'archive_space/api/client'
require 'archive_space/ead/ead_parser'
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
    unless (@ead_header.eadid_url_attribute.nil? ||
            @ead_header.eadid_url_attribute.include?('findingaids.cul.columbia.edu') ||
            @ead_header.eadid_url_attribute.include?('findingaids.library.columbia.edu'))
      @eadid_other_finding_aid_url = @ead_header.eadid_url_attribute
    end
    @cache_html = true unless @preview_flag
  end

  def print
    @print_view = true
    # @params_bib_id used by html caching functionality
    @params_bib_id = params[:finding_aid_id].delete_prefix('ldpd_').to_i
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

  def summary
    if @preview_flag
      redirect_to '/preview' + repository_finding_aid_path(id: params[:finding_aid_id])
    else
      redirect_to repository_finding_aid_path(id: params[:finding_aid_id])
    end
  end
end
